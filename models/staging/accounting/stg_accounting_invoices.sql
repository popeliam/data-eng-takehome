with src as (
    select 
        *
        , row_number() over (partition by id order by _TABLE_SUFFIX desc, modifiedDate desc) as rn
    from {{ source('accounting', 'invoices_v1') }}
) 

, renamed as (
    select
        id as invoice_id
        , invoiceNumber as invoice_number
        , customerRef.id as customer_id
        , customerRef.companyName as customer_name
        , date(issueDate) as invoice_issue_date
        , date(dueDate) as invoice_due_date
        , date(modifiedDate) as last_modified_date
        , date(paidOnDate) as invoice_paid_date
        , totalAmount as invoice_amount_total
        , amountDue as current_invoice_amount_due
        , status as invoice_status
        , paymentAllocations as payment_allocations
    from src
    where rn = 1
)

select * from renamed