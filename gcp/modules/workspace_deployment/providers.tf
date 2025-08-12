terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = ">=1.51.0"
      configuration_aliases = [databricks.accounts]
    }
    google = {
      source  = "hashicorp/google"
      version = ">=5.43.1"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}

# Use impersonation for Google provider - this allows the module to act as the service account
provider "google" {
  project = var.google_project
  region  = var.google_region
  
  # Impersonate the service account created by the service_account module
  impersonate_service_account = var.databricks_google_service_account != "" ? var.databricks_google_service_account : null
  
  # # Add explicit scopes
  # scopes = [
  #   "https://www.googleapis.com/auth/cloud-platform",
  #   "https://www.googleapis.com/auth/cloudkms",
  #   "https://www.googleapis.com/auth/compute"
  # ]
}

// initialize provider in "accounts" mode to provision new workspace
provider "databricks" {
  alias                  = "accounts"
  host                   = var.account_console_url
  google_service_account = var.databricks_google_service_account
  account_id             = var.databricks_account_id
  google_credentials = var.databricks_google_service_account_key != "" ? var.databricks_google_service_account_key : null
}

# provider "databricks" {
#  alias                  = "workspace"
#  host                   = databricks_mws_workspaces.this.workspace_url
#  google_service_account = var.databricks_google_service_account
# }

