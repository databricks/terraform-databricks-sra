# Security Reference Architecture Template

# Getting Started

1. Clone this Repo
2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
3. CD into `tf`
4. Using `template.tfvars.example` as starting point, supply your variables and place in `tf` directory
5. Run `terraform init`
6. Run `terraform validate`
7. From `tf` directory, run `terraform plan -var-file <YOUR_VAR_FILE>`, if edited directly, the command would be `terraform plan -var-file template.tfvars.example`
8. Run `terraform apply -var-file <YOUR_VAR_FILE`

<<<<<<< HEAD
<<<<<<< HEAD
## Note on provider initialization with Azure CLI
=======
## Note on provider initialization
>>>>>>> f715e43 (docs(azure): Add note on iss claim error)
If you are using [Azure CLI Authentication](https://registry.terraform.io/providers/databricks/databricks/latest/docs#authenticating-with-azure-cli),
you may encounter an error like the below:

```shell
Error: cannot create mws network connectivity config: io.jsonwebtoken.IncorrectClaimException: Expected iss claim to be: https://sts.windows.net/00000000-0000-0000-0000-000000000000/, but was: https://sts.windows.net/ffffffff-ffff-ffff-ffff-ffffffffffff/
```
This typically happens if you are running this Terraform in a tenant where you are a guest, or if you have multiple
Azure accounts configured. To resolve this error, set the Azure Tenant ID by exporting the `ARM_TENANT_ID` environment
variable:

```shell
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

Alternatively, you can set the tenant ID in the databricks provider configurations (see the provider [doc](https://registry.terraform.io/providers/databricks/databricks/latest/docs#special-configurations-for-azure) for more info.)

<<<<<<< HEAD
You may also encounter errors like the below when Terraform begins provisioning workspace resources:

```shell
╷
│ Error: cannot read current user: Unauthorized access to Org: 0000000000000000
│ 
│   with module.sat[0].module.sat.data.databricks_current_user.me,
│   on .terraform/modules/sat.sat/terraform/common/data.tf line 1, in data "databricks_current_user" "me":
│    1: data "databricks_current_user" "me" {}
│ 
╵
```

To fix this error, log in to the newly created spoke workspace by clicking on the "Launch Workspace" button in the Azure
portal. This must be done as the user who is running this Terraform, or the user running this Terraform must be granted
workspace admin after the first user launches the workspace.

=======
>>>>>>> b9834b2 (remove make items, doc update.)
=======
>>>>>>> f715e43 (docs(azure): Add note on iss claim error)
# Introduction

Databricks has worked with thousands of customers to securely deploy the Databricks platform with appropriate security features to meet their architecture requirements.

This Security Reference Architecture (SRA) repository implements common security features as a unified terraform templates that are typically deployed by our security conscious customers.

# Component Breakdown and Description

In this section, we break down each of the components that we've included in this Security Reference Architecture.

In various .tf scripts, we have included direct links to the Databricks Terraform documentation. The [official documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs) can be found here.

## Infrastructure Deployment

- **Vnet Injection**: [Vnet injection](https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/vnet-inject)
allows Databricks customers to exercise more control over your network configures to comply with specific cloud security and governance standards that a
customer's organization may require.

- **Private Endpoints**: Using Private Link technology, a [private endpoint](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) is a service that connects a customer's Vnet
to Azure services without traversing public IP addresses.

- **Private Link Connectivity**: Private Link provides a private network route from one Azure service to another.
[Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) is configured
so that communication between the customer's data plane and Databricks control plane does not traverse public IP addresses. Both front-end and back-end Private Link are set up in this template according
to the [Simplified Private Link](https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/private-link-simplified) setup.

- **Unity Catalog**:  [Unity Catalog](https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog) is a unified governance solution for all data and AI assets including
files, tables, and machine learning models. Unity Catalog provides a modern approach to granular access controls with centralized policy, auditing, and lineage tracking,
all integrated into your Databricks workflow.

## Post Workspace Deployment

- **Admin Console Configurations**: There are a number of configurations within the [admin console](https://docs.databricks.com/administration-guide/admin-console.html) that
can be controlled to reduce your threat vector. The AWS directory contains examples of configuring these, should your organization desire them.

- **Cluster Tags and Pool Tags**: [Cluster and pool tags](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/account-settings/usage-detail-tags) allow customers to
monitor cost and accurately attribute Databricks usage to your organization's business unit and teams (for chargebacks, for examples). These tags propagate to detailed
DBU usage reports for cost analysis.

<<<<<<< HEAD
## Security Analysis Tool
Security Analysis Tool ([SAT](https://github.com/databricks-industry-solutions/security-analysis-tool/tree/main)) is enabled by default. It can be customized using the `sat_configuration` variable. 
By default, SAT is installed in the hub workspace, also called the "WEB_AUTH" workspace.

### Changing the SAT workspace
To change which workspace SAT is installed in, there are three modifications required to the `customizations.tf`:

1. Change the Databricks provider used in the `SAT` module to use a different workspace
```hcl
# customizations.tf - default
# Default

# Change the provider if needed
providers = {
  databricks = databricks.hub #<---- This can be modified
}
```

```hcl
# customizations.tf - modified

# Change the provider if needed
providers = {
  databricks = databricks.spoke
}
```

2. Change the "sat_workspace" local to use the correct module
```hcl
# customizations.tf - default
locals {
  sat_workspace     = module.hub #<- This should be updated to the spoke you would like to use for SAT
}
```
```hcl
# customizations.tf - modified
locals {
  sat_workspace     = module.spoke #<- This should be updated to the spoke you would like to use for SAT
}
```

3. Change the `databricks_permission_assignment.sat_workspace_admin` resource to use the correct provider
```hcl
# customizations.tf - default
resource "databricks_permission_assignment" "sat_workspace_admin" {
  count = length(module.sat)
  ...
  provider = databricks.hub #<- This should be updated to the spoke you would like to use for SAT
}
```
```hcl
# customizations.tf - modified
resource "databricks_permission_assignment" "sat_workspace_admin" {
  count = length(module.sat)
  ...
  provider = databricks.spoke
}
```
Note that SAT is designed to be deployed _once per Azure subscription_. If needed, SAT can be deployed multiple times in
different regions using this terraform configuration. This requires provisioning SAT in multiple spokes. Reference the 
above modifications to deploy to multiple spokes.

### SAT Service Principal
Some users of SRA may not have permissions to create Entra ID service principals. If this is the case, you can choose to
bring-your-own service principal. To configure a pre-existing Entra ID service principal to be used for SAT, configure 
the `sat_service_principal` variable like the example below:

```hcl
# example.tfvars
sat_service_principal = {
  client_id     = "00000000-0000-0000-0000-000000000000"
  client_secret = "some-secret"
}
```

If you do not bring-your-own service principal, an Entra ID service principal will be created for you with a default
name of `spSAT`. This name can be customized by modifying the `sat_service_principal` variable like so:
```hcl
# example.tfvars
sat_service_principal = {
  name = "spSATDev"
}
```

### SAT Serverless Compute
SAT is installed using serverless compute by default. Before running the [required jobs](https://github.com/databricks-industry-solutions/security-analysis-tool/blob/v0.3.3/terraform/azure/TERRAFORM_Azure.md#step-7-run-databricks-jobs)
in Databricks, the private endpoints on your hub storage account must be approved.

## Adding additional spokes

To add additional spokes to this configuration, follow the below steps.

1. Add a new key to the spoke_config variable

```hcl
# Terraform variables (for example, terraform.tfvars)
spoke_config = {
  spoke = {
    resource_suffix = "spoke"
    cidr            = "10.1.0.0/20"
    tags = {
      environment       = "dev"
    },
  spoke_b = { #<----- Add a new spoke config
    resource_suffix = "spoke_b"
    cidr            = "10.2.0.0/20"
    tags = {
      environment       = "test"
    }
  }
}
```

2. Add a new provider to the providers.tf for the new spoke

```hcl
# providers.tf

# New spoke provider
provider "databricks" {
  alias = "spoke_b"
  host  = module.spoke_b.workspace_url
}
```

3. Copy the `spoke.tf` file to a new file (for example, `spoke_b.tf`).

4. Make the following adjustments to the new file

```hcl
# spoke_b.tf
module "spoke" { #<----- Modify the name of the module to something unique
  source = "./modules/spoke"

  # Update these per spoke
  resource_suffix = var.spoke_config["spoke"].resource_suffix #<----- Use a new key in the spoke_config variable
  vnet_cidr       = var.spoke_config["spoke"].cidr
  tags            = var.spoke_config["spoke"].tags

  ...

  depends_on = [module.hub]
}

module "spoke_catalog" { #<----- Rename this spoke's catalog to something unique
  source = "./modules/catalog"

  # Update these per catalog for the catalog's spoke
  catalog_name        = module.spoke.resource_suffix #<----- Replace all references to original spoke with new spoke
  dns_zone_ids        = [module.spoke.dns_zone_ids["dfs"]]
  ncc_id              = module.spoke.ncc_id
  resource_group_name = module.spoke.resource_group_name
  resource_suffix     = module.spoke.resource_suffix
  subnet_id           = module.spoke.subnet_ids.privatelink
  tags                = module.spoke.tags

  ...

  providers = {
    databricks.workspace = databricks.spoke #<----- Replace provider reference to new spoke
  }
}
```

```hcl
# spoke_b.tf - modified
module "spoke_b" {
  source = "./modules/spoke"

  # Update these per spoke
  resource_suffix = var.spoke_config["spoke_b"].resource_suffix
  vnet_cidr       = var.spoke_config["spoke_b"].cidr
  tags            = var.spoke_config["spoke_b"].tags
  
  ...
  
  depends_on = [module.hub]
}

module "spoke_b_catalog" {
  source = "./modules/catalog"

  # Update these per catalog for the catalog's spoke
  catalog_name        = module.spoke_b.resource_suffix
  dns_zone_ids        = [module.spoke_b.dns_zone_ids["dfs"]]
  ncc_id              = module.spoke_b.ncc_id
  resource_group_name = module.spoke_b.resource_group_name
  resource_suffix     = module.spoke_b.resource_suffix
  subnet_id           = module.spoke_b.subnet_ids.privatelink
  tags                = module.spoke_b.tags
  
  ...
  
  providers = {
    databricks.workspace = databricks.spoke_b
  }
}

```

5. Run `terraform apply` to create the new spoke

=======
>>>>>>> b9834b2 (remove make items, doc update.)
# Additional Security Recommendations and Opportunities

In this section, we break down additional security recommendations and opportunities to maintain a strong security posture that either cannot be configured into this
Terraform script or is very specific to individual customers (e.g. SCIM, SSO, etc.)

- **Segment Workspaces for Various Levels of Data Separation**: While Databricks has numerous capabilities for isolating different workloads, such as table ACLs and
IAM passthrough for very sensitive workloads, the primary isolation method is to move sensitive workloads to a different workspace. This sometimes happens when
a customer has very different teams (for example, a security team and a marketing team) who must both analyze different data in Databricks.

- **Avoid Storing Production Datasets in Databricks File Store**: Because the DBFS root is accessible to all users in a workspace, all users can access any data stored here.
It is important to instruct users to avoid using this location for storing sensitive data. The default location for managed tables in the Hive metastore on Databricks is the DBFS root;
to prevent end users who create managed tables from writing to the DBFS root, declare a location on external storage when creating databases in the Hive metastore.

- **Single Sign-On, Multi-factor Authentication, SCIM Provisioning**: Most production or enterprise deployments enable their workspaces to use
[Single Sign-On (SSO)](https://learn.microsoft.com/en-us/azure/databricks/security/auth-authz/#sso) and multi-factor authentication (MFA).
As users are added, changed, and deleted, we recommended customers integrate [SCIM (System for Cross-domain Identity Management)](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/users-groups/scim)
to their account console to sync these actions.

- **Backup Assets from the Databricks Control Plane**: While Databricks does not offer disaster recovery services, many customers use Databricks capabilities, including the Account API,
to create a cold (standby) workspace in another region. This can be done using various tools such as the Databricks [migration tool](https://github.com/databrickslabs/migrate),
[Databricks sync](https://github.com/databrickslabs/databricks-sync), or the [Terraform exporter](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/experimental-exporter)

- **Regularly Restart Databricks Clusters**: When you restart a cluster, it gets the latest images for the compute resource containers and the VM hosts. It is particularly important
to schedule regular restarts for long-running clusters such as those used for processing streaming data. If you enable the compliance security profile for your account or your workspace,
long-running clusters are automatically restarted after 25 days. Databricks recommends that admins restart clusters manually during a scheduled maintenance window.
This reduces the risk of an auto-restart disrupting a scheduled job.

- **Evaluate Whether your Workflow requires using Git Repos or CI/CD**: Mature organizations often build production workloads by using CI/CD to integrate code scanning,
better control permissions, perform linting, and more. When there is highly sensitive data analyzed, a CI/CD process can also allow scanning for known scenarios such as hard coded secrets.

# Network Diagram

![Architecture Diagram](https://cms.databricks.com/sites/default/files/inline-images/db-9734-blog-img-4.png)
