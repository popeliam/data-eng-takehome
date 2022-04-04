from functions import api, bigquery as bq
from source.schemas import schemas

def load_invoices(request):

    request_json = request.get_json()
    schema_version_name = request_json['schema_name']
    project = request_json['project']
    dataset = request_json['dataset']
    data_model = request_json['data_model']
    
    # load the requested schema from schema lookup in source/schemas.py
    schema = schemas[schema_version_name]
    
    # run the (simulated) api function from utils/api.py to get the data for ingestion
    json = api.fetch_invoices()

    # run the ingestion function from utils/bigquery.py
    load_result = bq.json_to_bigquery(json=json, project=project, dataset=dataset, data_model=data_model, schema=schema)

    return load_result