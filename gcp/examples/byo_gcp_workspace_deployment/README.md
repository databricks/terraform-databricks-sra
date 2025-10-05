# Self-Sufficient Databricks Workspace Deployment Template

This template creates a complete Databricks workspace deployment on Google Cloud Platform with customer-managed keys and private service connect. The pre-req GCP resources (VPC, Subnet, KMS Key, PSC Endpoints) have already been created. 
## Authentication Architecture

The template implements a pure Terraform impersonation-based authentication flow:

1. **workspace_deployment module**: Impersonates the provided service account for all Google Cloud operations

## What This Template Creates

1. **Google Cloud Infrastructure** 
   - None

2. **Databricks Account Setup**
   - Configures customer-managed keys and network configurations
   - Creates private access settings

3. **Databricks Workspace**
   - Deploys a complete workspace with customer-managed encryption
   - Configures security settings and IP access lists
   - Sets up secret scopes and workspace configurations

## Prerequisites

1. A Google Cloud project with billing enabled
2. A Databricks account with admin access  
3. Your current user authenticated

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
- ✅ **Clean authentication flow**: Current user→ impersonation → infrastructure deployment

## Authentication Flow Details

```
Your GCP Identity → Workspace Module Impersonates SA → Deploys Infrastructure
```

1. **Infrastructure deployment**: The workspace_deployment module impersonates the service account for all GCP operations
2. **Databricks operations**: Uses the service account identity for all Databricks API calls

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