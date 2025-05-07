---
page_title: "Workspace Deployment GCP SRA Modue"
---

# Module to deploy a Databricks workspace 

This module is provided as-is and you can use this guide as the basis for your custom Terraform module. This module is meant to be used either to provision a workspace with all the required GCP objects associated or to leverage existing objects, thus enabling use cases where CMEK, PSCs, and other artefacts that require higher privileges need to be provisionned through an external process and can't be provisionned through terraform.
The example folder aims at illustrating this through different use cases.

## Requirements
Running this module has the following requirements :
- Recent version of Terraform 
- Access to recent versions the Databricks Provider (```databricks/databricks```) and the google Provider (```hashicorp/google```)
- A Google Service Account with the GCP privileges defined in the module service_account and added to the Databricks Account Console as a **User** with the account admin privileges
- Depending on how much you are allowed to provision through this module, the values for the following variables

## Variables

This module uses the following variables in configurations:

- `databricks_account_id`: The ID per Databricks GCP account used for accessing account management APIs. After the GCP account is created, this is available after logging into [https://accounts.cloud.databricks.com](https://accounts.cloud.databricks.com).
- `databricks_google_service_account`: Service account used for programatically interacting with cloud infrastructure. More documentation [here](https://cloud.google.com/iam/docs/service-accounts)
- `google_project` - The name of the GCP project where the workspace is deployed.
- `google_region` - Region in which infrastructure is spun up.
- `account_console_url` - Databricks account console URL (always the same for a given cloud)
- `workspace_name` - Name you want to give to the Databricks workspace you are creating
- `use_existing_vpc` - Flag determining if you will be creating the VPC as a part of this module (you may provide an existing one).
- `existing_vpc_name` - Name of the VPC if use_existing_vpc=true. If use_existing_vpc=false, we are generating a random name.
- `existing_subnet_name` - Name of the subnet if use_existing_vpc=true. If use_existing_vpc=false, we are generating a random name.
- `nodes_ip_cidr_range` - CIDR range for nodes. See https://docs.databricks.com/gcp/en/admin/cloud-configurations/gcp/network-sizing for sizing details. This is important as it can't be changed after the workspace is created.
- `use_existing_PSC_EP` - Flag determining if you will be creating PSC Endpoints as a part of this module (you may provide an existing one). 
- `google_pe_subnet` - Name of the subnet where the PSC Endpoints will be provided
- `google_pe_subnet_ip_cidr_range` - CIDR of the PE subnet. Needed only if use_existing_PSC_EP=false
- `workspace_pe` - Name of the PSC endpoint used for the workspace communication. If you are creating it you may decide its value. 
- `relay_pe` - Name of the PSC endpoint used for the SCC relay communication. If you are creating it you may decide its value. 
- `workspace_pe_ip_name` - Name of the workspace private endpoint IP.If use_existing_PSC_EP = true, not needed. If use_existing_PSC_EP = true, you may decide its value.
- `relay_pe_ip_name` - Name of the Relay IP. If use_existing_PSC_EP = true, not needed. If use_existing_PSC_EP = true, you may decide its value.
- `harden_network` - Flag determining if we are closing VPC access by default and only opening the minimum required communication.
- `hive_metastore_ip` - IP to the regional Metastore. This value can be found here - https://docs.gcp.databricks.com/en/resources/ip-domain-region.html#addresses-for-default-metastore. The module will create an Egress opening to this IP Address. This will be soon deprecated as we are shifting away from this communication.
- `ip_addresses` - list of IP addresses from which to access the workspace.
- `use_existing_pas` - flag to use an existing Private Access Settings (Databricks Object)
- `existing_pas_id` - if above is true, the ID of the setting (found in the account console)
- `relay_service_attachment` - Relay service attachment. regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
- `workspace_service_attachment` - Workspace service attachment. Regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc

- `use_existing_cmek` - flag ("true" or "false") allowing for either the mode where you provide the resource ID to your CMEK resource, or let the module create a new one by providing key_name and keyring_name
- `key_name` & `keyring_name` - name to be given to the CMEK used by Databricks for encryption. Not useful if bringing an existing `cmek_resource_id`
- `cmek_resource_id` - ID to your existing CMEK. Only needed if use_existing_cmek = true


