terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = ">=1.51.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">=5.43.1"
    }
  }
}

# # Default provider for service account creation (uses your current auth)
provider "google" {
  project = var.google_project
  region  = var.google_region
}

# # Databricks provider for account operations
provider "databricks" {
  alias                  = "accounts"
  host                   = "https://accounts.gcp.databricks.com"
  account_id             = var.databricks_account_id
}