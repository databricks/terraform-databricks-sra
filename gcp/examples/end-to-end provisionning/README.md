# Self-Sufficient Databricks Workspace Deployment Template

This template creates a complete Databricks workspace deployment on Google Cloud Platform with customer-managed keys, private networking, and pure Terraform-based authentication using service account impersonation.

## Authentication Architecture

The template implements a pure Terraform impersonation-based authentication flow:

1. **service_account module**: Uses your current user identity to create and configure the service account
2. **make_sa_dbx_admin module**: Uses your current user identity to grant Databricks admin rights to the service account  
3. **workspace_deployment module**: Impersonates the created service account for all Google Cloud operations

## What This Template Creates

1. **Service Account with Comprehensive Permissions**
   - Creates a service account with all necessary GCP permissions including `iam.serviceAccounts.getOpenIdToken`
   - Sets up impersonation permissions for the current user
   - **No service account keys required** - uses pure impersonation

2. **Google Cloud Infrastructure** 
   - KMS key ring and crypto key for encryption
   - VPC with private subnets and secure firewall rules
   - All networking components for Databricks

3. **Databricks Account Setup**
   - Makes the service account an admin in the Databricks account
   - Configures customer-managed keys and network configurations
   - Creates private access settings

4. **Databricks Workspace**
   - Deploys a complete workspace with customer-managed encryption
   - Configures security settings and IP access lists
   - Sets up secret scopes and workspace configurations

## Prerequisites

1. A Google Cloud project with billing enabled
2. A Databricks account with admin access  
3. Your current user authenticated with `gcloud auth application-default login`

## Usage

1. **Set your variables** in `terraform.tfvars`:
   ```hcl
   google_project = "your-gcp-project-id"
   google_region = "europe-west1" 
   databricks_account_id = "your-databricks-account-id"
   workspace_name = "your-workspace-name"
   sa_name = "databricks-workspace-creator"
   delegate_from = []
   ```

2. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform apply
   ```

## Self-Sufficiency Features

- ✅ **Pure Terraform**: No external scripts or manual steps required
- ✅ **Impersonation-based**: Uses service account impersonation instead of key files
- ✅ **No secrets management**: No service account keys to secure or rotate
- ✅ **Automatic permission setup**: Configures all required IAM permissions automatically
- ✅ **Clean authentication flow**: Current user → service account creation → impersonation → infrastructure deployment

## Authentication Flow Details

```
Your GCP Identity → Creates Service Account → Grants Impersonation Rights → Workspace Module Impersonates SA → Deploys Infrastructure
```

1. **Initial phase**: Your personal GCP credentials create the service account and configure permissions
2. **Impersonation setup**: The service account is granted necessary permissions and your user gets impersonation rights  
3. **Infrastructure deployment**: The workspace_deployment module impersonates the service account for all GCP operations
4. **Databricks operations**: Uses the service account identity for all Databricks API calls

## Security Benefits

- **No long-lived credentials**: No service account keys to manage or secure
- **Audit trail**: All operations traced back to your user identity through impersonation
- **Least privilege**: Service account only has permissions needed for Databricks workspace deployment
- **Automatic cleanup**: No credential files left on disk

## Files Created

- `terraform.tfstate` - Terraform state file
- `.terraform/` - Provider and module cache (standard Terraform files)

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

This removes all created resources including the service account.