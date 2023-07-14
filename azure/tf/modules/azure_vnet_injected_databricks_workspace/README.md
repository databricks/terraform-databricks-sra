---
page_title: "Provisioning Azure Databricks Workspaces with Private Link and Data Exfiltration Protection with Terraform"
---

# How to Deploy a Secure Azure Databricks Workspace, Hardened To Prevent Data Exfiltration

This guide uses the following variables in configurations:

- `workspace_name`: Desired Databricks workspace name
- `databricks_resource_group_name`: Name of resource group into which Databricks will be deployed
- `location` - Location in which Databricks will be deployed
- `vnet_id` - ID of existing virtual network into which Databricks will be deployed
- `vnet_name` - Name of existing virtual network into which Databricks will be deployed
- `nsg_id` - ID of existing Network Security Group
- `route_table_id` - ID of existing Route Table
- `private_subnet_address_prefixes` - Address space for private Databricks subnet
- `public_subnet_address_prefixes` - Address space for public Databricks subnet
- `tags` - Map of tags to attach to Databricks workspace
- `region` - Region in which infrastructure is spun up.

This guide is provided as-is and you can use this guide as the basis for your custom Terraform module. This module creates the Azure Databricks workspace based on the hub and spoke architecture. The spoke module is in the same folder as this module and available to use before using this module.

## Provider initialization

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.13.0"
    }
  }
}

```
