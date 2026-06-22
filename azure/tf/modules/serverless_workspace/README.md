# serverless_workspace

Provisions a serverless-only Azure Databricks workspace using the
`Microsoft.Databricks/workspaces` ARM API (`computeMode = "Serverless"`) via the
AzAPI provider.

## Why this module exists

The `azurerm_databricks_workspace` resource in the AzureRM provider does **not**
support serverless workspaces — it cannot set `computeMode`, which is a
create-only property of the ARM resource. This module is a temporary
workaround built on AzAPI directly until that gap is closed in AzureRM.

Tracking issue: [hashicorp/terraform-provider-azurerm#31218 — Support for
serverless Azure Databricks workspaces](https://github.com/hashicorp/terraform-provider-azurerm/issues/31218).

Once that lands, this module will be retired in favor of a normal
`azurerm_databricks_workspace` configured with the equivalent serverless
attribute.
