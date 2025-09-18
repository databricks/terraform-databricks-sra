
## Prerequisites

Before you begin, ensure you have:

- **A Google Service Account (GSA):**  
    An existing GSA to manage resources.

- **Required Permissions:**  
    The GSA must have all necessary permissions. [See required permissions.](https://docs.databricks.com/gcp/en/admin/cloud-configurations/gcp/permissions) 

- **Databricks Admin Role:**  
    The GSA must be assigned as a Databricks Admin.

- **Authenticated Session:**  
    You are logged in as this GSA using either `gcloud auth` or by setting the `GOOGLE_SERVICE_CREDENTIALS` environment variable.

---

## What This Example Does

This deployment will:

1. **Provision GCP Resources:**  
     Deploys required GCP resources with existing CMEK and endpoints enabled.

2. **Deploy a Databricks Workspace:**  
     Sets up a new Databricks workspace.

3. **Configure Unity Catalog:**  
     Assigns Unity Catalog controls for data governance.
