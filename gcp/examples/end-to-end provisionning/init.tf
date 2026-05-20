terraform {
  # Remote state backend.
  # Uncomment the `backend "gcs" {}` line below to store state in GCS instead
  # of the local filesystem. Provide bucket and prefix at init time:
  #   terraform init \
  #     -backend-config="bucket=my-tfstate-bucket" \
  #     -backend-config="prefix=databricks/end-to-end"
  # If left commented, Terraform uses the default local backend
  # (terraform.tfstate in this directory).
  # backend "gcs" {}

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.113.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">=5.43.1"
    }
  }
}

# Default Google provider (uses your current auth).
provider "google" {
  project = var.google_project
  region  = var.google_region
}

# SRA template version — bump on each major release of this repo.
# Surfaced via user_agent_extra so Databricks-side telemetry can identify SRA deployments.
locals {
  sra_version = "1.0"
}

# Databricks provider for account operations.
provider "databricks" {
  alias            = "accounts"
  host             = "https://accounts.gcp.databricks.com"
  account_id       = var.databricks_account_id
  user_agent_extra = "terraform-databricks-sra/gcp/v${local.sra_version}"
}
