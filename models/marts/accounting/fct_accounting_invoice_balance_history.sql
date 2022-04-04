with invoices as (
    select *
    from {{ ref('dim_accounting_invoices') }}
)

, payments as (
    select * 
    from {{ ref('fct_accounting_invoice_payments') }}
)

-- generate dates from the first reporting date available (day following the first invoice) and today
, dates as (
    select *
    from unnest(generate_date_array((select min(invoice_issue_date) from invoices) + 1, current_date(), interval 1 day)) as report_date
)

-- This cte calculates two things for each payment:
-- a) the sum of the payment plus all of the payments preceeding it within that invoice
-- b) The dates during which the payment was the most recent payment made on the invoice 
, invoice_payment_history as (
    select
        payment_id 
        , invoice_id
        , payment_date as from_date
        , sum(payment_amount) over (
            partition by invoice_id 
            order by payment_date asc, payment_id asc
        ) as paid_to_date
        , coalesce(
                lead(payment_date - 1) over ( -- minus one because on that date we will want to join the next payment
                    partition by invoice_id 
                    order by payment_date asc, payment_id asc -- if there are multiple payments on the same date, ensure the ranking will always return the same invoice across dbt runs
                )
                , current_date()
        ) as to_date
    from payments
)

-- Join each invoice to all dates beginning when it was issued 
-- This pattern might not be the best at scale, we could remove invoices from the table once they've been fully paid
-- Also join the total payments paid to date for the given date
, daily as (
    select 
        dates.report_date
        , invoices.customer_name
        , invoices.invoice_issue_date
        , invoices.invoice_due_date
        , invoices.invoice_id
        , coalesce(invoices.invoice_amount_total, 0) as invoice_amount_total
        , coalesce(invoice_payment_history.paid_to_date, 0) as invoice_amount_paid_to_date
    from dates
    left join invoices
        on invoices.invoice_issue_date < dates.report_date
    left join invoice_payment_history
        on invoice_payment_history.invoice_id = invoices.invoice_id
        and dates.report_date between invoice_payment_history.from_date and invoice_payment_history.to_date
)

-- Calculate the status & amount outstanding based on the payments made to date
, renamed as (
    select 
        report_date
        , customer_name
        , invoice_issue_date
        , invoice_due_date
        , invoice_id
        , case 
            when invoice_amount_paid_to_date = 0 then 'Submitted'
            when invoice_amount_paid_to_date >= invoice_amount_total then 'Paid'
            else 'PartiallyPaid'
        end as invoice_payment_status
        , invoice_amount_total
        , invoice_amount_paid_to_date
        , invoice_amount_total - invoice_amount_paid_to_date as invoice_amount_outstanding
    from daily
)

select * from renamed