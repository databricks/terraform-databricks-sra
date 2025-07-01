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

provider "google" {
  project = var.google_project
  region  = var.google_region
  # impersonate_service_account = var.databricks_google_service_account
}

// initialize provider in "accounts" mode to provision new workspace
provider "databricks" {
  alias                  = "accounts"
  host                   = var.account_console_url
  account_id             = var.databricks_account_id
}

provider "databricks" {
  alias                  = "workspace"
  host                   = databricks_mws_workspaces.this.workspace_url
  account_id             = var.databricks_account_id
  impersonate_service_account = var.databricks_google_service_account
  
}

