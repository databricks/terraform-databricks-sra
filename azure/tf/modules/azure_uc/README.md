---
page_title: "Enabling Unity Catalog on Azure Databricks"
---

# Set up a metastore, required infrastructure, and metastore assignments with a set of Azure Databricks workspaces

This guide uses the following variables in configurations:

- `resource_group_id`: resource group in Azure to associate all infrastructure used for the Unity Catalog metastore
- `workspaces_to_associate`: List of workspaces to associate with created metastore

This guide is provided as-is and you can use this guide as the basis for your custom Terraform module. 

## Provider initialization

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.30.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.6.4"
    }
  }
}
```
