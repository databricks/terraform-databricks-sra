# Security Reference Architectures (SRA) - Terraform Templates

<p align="center">
  <img src="https://i.ibb.co/NrfH2qc/Screenshot-2024-09-17-at-1-02-06-PM.png" />
</p>

## Project Overview

Security Reference Architecture (SRA) with Terraform templates makes deploying workspaces with Security Best Practices easy. You can programmatically deploy workspaces and the required cloud infrastructure using the official Databricks Terraform provider. These unified Terraform templates are pre-configured with hardened security settings similar to our most security-conscious customers. The initial templates based on [Databricks Security Best Practices](https://www.databricks.com/trust/security-features#best-practices)

- [AWS](https://github.com/databricks/terraform-databricks-sra/tree/main/aws)
- [AWS Govcloud](https://github.com/databricks/terraform-databricks-sra/tree/main/aws-gov)
- [Azure](https://github.com/databricks/terraform-databricks-sra/tree/main/azure)
- [GCP](https://github.com/databricks/terraform-databricks-sra/tree/main/gcp)

## Project support

Please note the code in this project is provided for your exploration only, and are not formally supported by Databricks with Service Level Agreements (SLAs). They are provided AS-IS and we do not make any guarantees of any kind. Please do not submit a support ticket relating to any issues arising from the use of these projects. The source in this project is provided subject to the Databricks [License](./LICENSE). All included or referenced third party libraries are subject to the licenses set forth below.

Any issues discovered through the use of this project should be filed as GitHub Issues on the Repo. They will be reviewed as time permits, but there are no formal SLAs for support.

### Example of `dev.tfvars` File

To customize the Terraform configuration for your development environment, create a `dev.tfvars` file with the following content:

```hcl
# Required Variables
application_id = "your-application-id"
databricks_account_id = "your-databricks-account-id"
location = "your-region"

hub_vnet_cidr = "10.0.0.0/16"
hub_resource_group_name = "your-hub-resource-group-name"
hub_vnet_name = "your-hub-vnet-name"

test_vm_password = "your-vm-password"
client_secret = "your-client-secret"
databricks_app_object_id = "your-databricks-app-object-id"

# Optional Variables
public_repos = [
  "python.org",
  "*.python.org",
  "pypi.org",
  "*.pypi.org",
  "pythonhosted.org",
  "*.pythonhosted.org",
  "cran.r-project.org",
  "*.cran.r-project.org",
  "r-project.org"
]

spoke_config = [
  {
    prefix = "spoke1"
    cidr   = "10.1.0.0/16"
    tags   = {
      environment = "dev"
      owner       = "team1"
    }
  },
  {
    prefix = "spoke2"
    cidr   = "10.2.0.0/16"
    tags   = {
      environment = "prod"
      owner       = "team2"
    }
  }
]

tags = {
  environment = "dev"
  owner       = "your-team-name"
}
```

## Using the Makefile

The provided Makefile simplifies working with Terraform configurations for different platforms and environments. Below is a guide on how to use it.

### Running the Makefile for Different Platforms

1. **Set the `PLATFORM` Variable**
   Change the `PLATFORM` variable to the desired platform before calling the Makefile. Supported platforms include:
   - `aws`
   - `aws-gov`
   - `azure`
   - `gcp`

2. **Specify the `ENV` Variable**
   Set the `ENV` variable to the target environment (e.g., `dev`, `stg`, `prod`).

3. **Terraform Directory and Variables**
   - The `TERRAFORM_DIR` variable points to the Terraform configuration directory for the selected platform.
   - The `VARS` variable specifies the path to the `.tfvars` file for the chosen environment.

### Example Command

#### AWS
```bash
PLATFORM=aws ENV=dev make plan
PLATFORM=aws ENV=dev make apply
PLATFORM=aws ENV=dev make destroy
```
