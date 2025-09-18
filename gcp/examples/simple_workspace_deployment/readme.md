

### Prerequisites

1. Existing Google Service Account
2. That GSA has the required permissions (add link)
3. That GSA is Databricks Admin
4. Logged in as this GSA (either gcloud auth or GOOGLE_SERVICE_CREDENTIALS)

### What it does
1. Deploys GCP resources (existing_cmek=True, existing_endpoints=True,)
2. Deploys a workspace 
3. Assigns Unity Catalog controls