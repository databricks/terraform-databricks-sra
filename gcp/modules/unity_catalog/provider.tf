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
}