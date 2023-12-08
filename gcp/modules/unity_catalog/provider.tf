terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "google" {
  project = var.project
}


provider "databricks" {
 alias                  = "workspace"
 host                   = var.databricks_workspace_url
 google_service_account = var.databricks_google_service_account
 version = "1.18.0"
}

// initialize provider in "MWS" mode for account-level resources
provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.staging.gcp.databricks.com"
  account_id = var.databricks_account_id
  google_service_account = var.databricks_google_service_account
  version = "1.18.0"
}

