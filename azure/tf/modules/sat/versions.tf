terraform {
  required_version = ">=1.0"
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = ">=1.116"
      configuration_aliases = [databricks.workspace]
    }
  }
}
