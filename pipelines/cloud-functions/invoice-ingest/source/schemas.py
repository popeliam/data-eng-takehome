from google.cloud import bigquery

# define the bigquery schema for the invoice json here
# this is written to support different schemas - if it ever changes, 
# the new version could just be added here

schemas = {
    "v1":
        [
            bigquery.SchemaField("id", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("invoiceNumber", "STRING", mode="NULLABLE"),
            bigquery.SchemaField(
                "customerRef",
                "RECORD",
                mode="NULLABLE",
                fields=[
                    bigquery.SchemaField("id", "STRING", mode="NULLABLE"),
                    bigquery.SchemaField("companyName", "STRING", mode="NULLABLE"),
                ]
            ),
            bigquery.SchemaField("issueDate", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("dueDate", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("modifiedDate", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("sourceModifiedDate", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("paidOnDate", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("totalAmount", "NUMERIC", mode="NULLABLE"),
            bigquery.SchemaField("amountDue", "NUMERIC", mode="NULLABLE"),
            bigquery.SchemaField("status", "STRING", mode="NULLABLE"),
            bigquery.SchemaField(
                "paymentAllocations",
                "RECORD",
                mode="REPEATED",
                fields=[
                    bigquery.SchemaField(
                        "payment",
                        "RECORD",
                        mode="NULLABLE",
                        fields=[
                            bigquery.SchemaField("id", "STRING", mode="NULLABLE"),
                            bigquery.SchemaField("paidOnDate", "STRING", mode="NULLABLE"),
                            bigquery.SchemaField("totalAmount", "DECIMAL", mode="NULLABLE")
                        ]
                    ),
                ]
            ),
        ],
}
