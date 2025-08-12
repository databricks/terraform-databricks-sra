

terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = ">=1.39.0"

    }
    google = {
      source  = "hashicorp/google"
    }

  }
}
provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = var.databricks_account_id
  google_service_account = var.dbx_existing_admin_account
}
