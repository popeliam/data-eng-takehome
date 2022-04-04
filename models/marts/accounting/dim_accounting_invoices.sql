with invoices as (
    select 
        invoice_id
        , invoice_number
        , customer_id
        , customer_name
        , invoice_issue_date
        , invoice_due_date
        , last_modified_date
        , invoice_paid_date
        , invoice_amount_total
        , current_invoice_amount_due
        , invoice_status
    from {{ ref('stg_accounting_invoices') }}
)

select * from invoices