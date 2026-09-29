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
4. If `admin_user` is a human user: a Databricks CLI account profile from
   `databricks auth login --host https://accounts.gcp.databricks.com --account-id <id>`,
   referenced via `databricks_cli_profile`

## Usage

1. **Set your variables** in `terraform.tfvars`:
   ```hcl
   # Core identifiers
   databricks_account_id = "your-databricks-account-id"
   google_project        = "your-gcp-project-id"
   google_region         = "europe-west1"
   workspace_name        = "your-workspace-name"
   sa_name               = "sra-workspace-creator"

   # Identity running Terraform. delegate_from must include it so it can
   # impersonate the provisioning SA; admin_user bootstraps account_admin and is
   # granted workspace admin.
   delegate_from = ["user:you@example.com"]
   admin_user    = "you@example.com"

   # When admin_user is a human user, point this at a `databricks auth login`
   # account profile so Terraform can bootstrap account_admin for the new SA.
   # Leave empty if admin_user is a service account (it will be impersonated).
   databricks_cli_profile = "ACCOUNT-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

   # PSC service attachments for your region. Look them up at:
   # https://docs.databricks.com/gcp/en/resources/ip-domain-region
   workspace_service_attachment = "projects/general-prod-<region>/regions/<region>/serviceAttachments/plproxy-psc-endpoint-all-ports"
   relay_service_attachment     = "projects/prod-gcp-<region>/regions/<region>/serviceAttachments/ngrok-psc-endpoint"

   # CMEK key names (created by the module)
   keyring_name = "databricks-keyring"
   key_name     = "databricks-key"
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

Tear down in **two steps**. The workspace_deployment module impersonates the
provisioning service account, but Terraform does not treat the SA's IAM role
binding as a dependency of the resources that binding is used to manage. A single
`terraform destroy` can therefore delete the role binding before the VPC/PSC
resources it needs, causing 403 errors. Destroying the workspace module first
(while the SA and its role are still intact), then the rest, avoids this:

```bash
# Step 1: destroy the workspace + its GCP resources while the SA still has its role
terraform destroy -target=module.customer_managed_vpc

# Step 2: destroy everything else (service account, custom role, account admin user)
terraform destroy
```

Notes:
- The KMS crypto key sets `prevent_destroy`. If you intend to tear the workspace
  down, comment out that `lifecycle` block in `modules/workspace_deployment/cmek.tf`
  first (KMS key rings/keys cannot be hard-deleted by GCP regardless).
- The workspace's compute VMs are torn down asynchronously after the workspace is
  deleted; if a subnet delete reports `resourceInUseByAnotherResource`, wait for
  those VMs to clear and re-run step 1.