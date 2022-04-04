# Placeholder for a script that fetches data from the source api
# For this exercise it's just loading the sample file
# In a different pattern, the invoice json could be loaded into 
# a GCP bucket and the file uri could be passed directly to this 
# function as a request argument in main.load_invocies

import json

def fetch_invoices():
    with open('invoices.json','r') as f:
        data = json.load(f)
    
    return data["results"]