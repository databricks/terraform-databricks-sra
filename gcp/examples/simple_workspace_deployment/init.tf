terraform {
  # Remote state backend.
  # Uncomment the `backend "gcs" {}` line below to store state in GCS instead
  # of the local filesystem. Provide bucket and prefix at init time:
  #   terraform init \
  #     -backend-config="bucket=my-tfstate-bucket" \
  #     -backend-config="prefix=databricks/simple_workspace_deployment"
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

provider "google" {
  project = var.project
}

provider "databricks" {
  alias      = "accounts"
  host       = var.account_console_url
  account_id = var.databricks_account_id
}
