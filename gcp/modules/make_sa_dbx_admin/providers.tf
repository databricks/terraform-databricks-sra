

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.39.0"

    }
    google = {
      source = "hashicorp/google"
    }

  }
}
# SRA template version — bump on each major release of this repo.
# Surfaced via user_agent_extra so Databricks-side telemetry can identify SRA deployments.
locals {
  sra_version = "1.0.0"
}

provider "databricks" {
  host                   = "https://accounts.gcp.databricks.com"
  account_id             = var.databricks_account_id
  google_service_account = var.dbx_existing_admin_account
  user_agent_extra       = "terraform-databricks-sra/gcp/v${local.sra_version}"
}
