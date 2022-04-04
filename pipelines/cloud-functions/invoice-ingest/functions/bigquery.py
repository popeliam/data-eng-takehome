from google.cloud import bigquery
import datetime

# biquery will throw an error if the dataset doesn't exist yet
# this function will check if it exists by sending a request 
# and create the dataset if that request fails
def create_dataset_if_not_exists(dataset_id, client):
    try:
        client.get_dataset(dataset_id)
    except:
        dataset = bigquery.Dataset(dataset_id)
        dataset.location = "US"
        job = client.create_dataset(dataset, timeout=30) # wait for the dataset to be created

def json_to_bigquery(json, project, dataset, data_model, schema):
    client = bigquery.Client()

    dataset_id = '.'.join([project, dataset])
    create_dataset_if_not_exists(dataset_id, client)

    # generate the destination table id with a suffixed load timestamp 
    base_table_id = '.'.join([project, dataset, data_model])
    now = datetime.datetime.now()
    suffix = now.strftime('%Y_%m_%d_%H_%M_%S')
    table_id = f'{base_table_id}_{suffix}'

    # configure the load job to create a table with the specified schema from source/schemas 
    job_config = bigquery.LoadJobConfig(schema=schema)

    job = client.load_table_from_json(json, table_id, job_config=job_config)
    response = job.result() # wait for the job to complete
    
    # fetch the new table's metadata
    table = client.get_table(table_id)
    
    return f'Loaded {table.num_rows} records to {table_id}'
