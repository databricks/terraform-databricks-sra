variable "databricks_account_id" {}
variable "new_admin_account" {}
variable "dbx_existing_admin_account" {
  description = "Existing Databricks SA or user. Allows either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"

}

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
  google_service_account = var.dbx_existing_admin_account
  account_id = var.databricks_account_id

}

