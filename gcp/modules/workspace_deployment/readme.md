---
page_title: "Provisioning Secure Databricks Workspaces on GCP with Terraform"
---

# How to Deploy a Lakehouse Blueprint using Best Practices and Industry Helper Libraries

This guide uses the following variables in configurations:

- `databricks_account_id`: The ID per Databricks GCP account used for accessing account management APIs. After the GCP account is created, this is available after logging into [https://accounts.cloud.databricks.com](https://accounts.cloud.databricks.com).
- `databricks_google_service_account`: Service account used for programattically interacting with cloud infrastructure. More documentation [here](https://cloud.google.com/iam/docs/service-accounts)
- `delegate_from` - The user principal can be allowed to impersonate a service account using this parameter. Set to a user principal who should impersonate a service account for purposes of account infrastructure provisioning and workspace setup.
- `google_credentials` - JSON parameter used for authenticating a service account
- `google_impersonate_service_account` - Service account email which is being impersonated in the flow mentioned above.
- `google_project` - Top level abstraction used to organized all GCP resources
- `prefix` - Prefix used to tag resources in this workflow
- `project_id` - Numeric ID for project
- `gcp_auth_file` - JSON keys for service account. DO NOT place this file in this project.
- `env` - Environment used to spin up infrastructure. This is merely a tag.
- `region` - Region in which infrastructure is spun up.
- `network_id` - UUID which is created once the Network Configuration is created via the Databricks account console for GCP. This should be created using the IP range, secondary ranges, and Google Compute Network is created.
- `use_existing_key` - flag ("true" or "false") allowing for either the mode where you provide the resource ID to your CMEK resource, or let the module create a new one by providing key_name and keyring_name
- `key_name` & `keyring_name` - name to be given to the CMEK used by Databricks for encryption. Not useful if bringing an existing `cmek_resource_id`
- `cmek_resource_id` - ID to your existing CMEK. 
- `hive_metastore_ip` - IP to the regional Metastore. This value can be found here - https://docs.gcp.databricks.com/en/resources/ip-domain-region.html#addresses-for-default-metastore. The module will create an Egress opening to this IP Address.

This guide is provided as-is and you can use this guide as the basis for your custom Terraform module. Note that for BYO VPC (a.k.a. customer managed VPC), there is a 2-step process as full automation via the tradition `databricks_mws_networks` is not supported at this time for GCP.

Workaround:

1. Run `apply` without the workspace.tf file to create all infrastructure and Databricks-compliant VPC with Cloud NAT.
2. Run `apply` with workspace.tf to create the workspace once the `network_id` (see description above in variables) is created with the GCP accounts console (Cloud Resouces).

To get started, this code walks you through the following high-level steps:

- Initialize the required providers
- Configure GCP objects
  - A VPC which satisfies the Databricks GCP networking [requirements](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/customer-managed-vpc.html#network-requirements-1)
  - A Cloud NAT which is used for routing egress to public internet
  - Private Subnets
- Workspace Creation

## Provider initialization

Initialize [provider with `mws` alias](https://www.terraform.io/language/providers/configuration#alias-multiple-provider-configurations) to set up account-level resources.

```hcl
provider "google" {
 project = var.google_project
 region  = var.region
 zone    = var.zone
}

terraform {
 required_providers {
   databricks = {
     source  = "databrickslabs/databricks"
   }
 }
}


```
