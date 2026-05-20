terraform {
  # Note: no backend block here. This module is intended to be consumed from a
  # root configuration (e.g. gcp/examples/*) that declares its own backend.
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = ">=1.113.0"
      configuration_aliases = [databricks.accounts]
    }
    google = {
      source  = "hashicorp/google"
      version = ">=5.43.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Use impersonation for the Google provider - this allows the module to act as the service account.
provider "google" {
  project = var.google_project
  region  = var.google_region

  impersonate_service_account = var.databricks_google_service_account != "" ? var.databricks_google_service_account : null
}

# SRA template version — bump on each major release of this repo.
# Surfaced via user_agent_extra so Databricks-side telemetry can identify SRA deployments.
locals {
  sra_version = "1.0.0"
}

# Databricks provider in "accounts" mode to provision a new workspace.
provider "databricks" {
  alias                  = "accounts"
  host                   = var.account_console_url
  google_service_account = var.databricks_google_service_account
  account_id             = var.databricks_account_id
  user_agent_extra       = "terraform-databricks-sra/gcp/v${local.sra_version}"
}

# Databricks provider scoped to the deployed workspace.
provider "databricks" {
  alias                  = "workspace"
  host                   = databricks_mws_workspaces.this.workspace_url
  google_service_account = var.databricks_google_service_account
  user_agent_extra       = "terraform-databricks-sra/gcp/v${local.sra_version}"
}
