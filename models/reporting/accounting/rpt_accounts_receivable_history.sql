-- Categorize each invoice date record to its accounts recievable bucket
with invoice_history as (
    select 
        * 
        , case
            when date_diff(report_date, invoice_due_date, day) < 0 then 'AR_current'
            when date_diff(report_date, invoice_due_date, day) <= 30 then 'AR_0_30'
            when date_diff(report_date, invoice_due_date, day) <= 60 then 'AR_31_60'
            else 'AR_61plus'
        end as ar_bucket
    from {{ ref('fct_accounting_invoice_balance_history') }}
)

-- fetch all dates from invoice history
, dates as (
    select distinct
        report_date
    from invoice_history
)

-- Fetch all customers so we can cross join them to dates (assuming we want to include customers in the report even if they haven't had an invoice as of the given date)
-- This isn't actually necessary for the sample data but best practice if this is the output we want
, customers as (
    select distinct
        customer_name
    from invoice_history
)

-- Populate rows with every date and every customer and for each date, sum all the invoices that fall under the AR buckets
, invoice_rollup as (
    select
        dates.report_date
        , customers.customer_name
        , sum(if(invoice_history.ar_bucket = 'AR_current', invoice_history.invoice_amount_outstanding, 0)) as AR_current
        , sum(if(invoice_history.ar_bucket = 'AR_0_30', invoice_history.invoice_amount_outstanding, 0)) as AR_0_30
        , sum(if(invoice_history.ar_bucket = 'AR_31_60', invoice_history.invoice_amount_outstanding, 0)) as AR_31_60
        , sum(if(invoice_history.ar_bucket = 'AR_61plus', invoice_history.invoice_amount_outstanding, 0)) as AR_61plus
    from dates
    cross join customers
    left join invoice_history
        on invoice_history.report_date = dates.report_date
            and invoice_history.customer_name = customers.customer_name
    group by 1,2
)

select * from invoice_rollup
order by report_date, customer_name