terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.113.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">=5.43.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
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

# NOTE: the previous "mws" (account-level) provider was removed — it was unused
# by any resource in this module and pointed at a staging control-plane host. All
# resources here use the workspace-scoped provider above.
