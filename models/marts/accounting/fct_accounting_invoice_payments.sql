with invoices as (
    select * 
    from {{ ref('stg_accounting_invoices') }}
)

, renamed as (
    select 
        payments.payment.id as payment_id
        , invoices.invoice_id
        , invoices.invoice_number
        , invoices.customer_id
        , invoices.customer_name
        , date(payments.payment.paidOnDate) as payment_date
        , payments.payment.totalAmount as payment_amount
    from invoices, unnest(payment_allocations) as payments
    where payments.payment.id is not null
)

select * from renamed