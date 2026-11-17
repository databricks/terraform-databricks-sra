

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
provider "databricks" {
  # Bootstrap credential used to grant the newly-created provisioning SA
  # account_admin. Auth precedence:
  #  1. databricks_cli_profile — a `databricks auth login` account profile. Use
  #     this when the existing admin is a human user. It is block-scoped, so it
  #     does NOT collide with other databricks providers in the same config that
  #     use google service-account impersonation.
  #  2. else, if dbx_existing_admin_account is a service account, impersonate it.
  #  3. else, fall back to ambient/default Databricks auth.
  #
  # NOTE: passing a *user* email to google_service_account (the old behavior)
  # breaks auth, because that field expects a service-account email.
  profile    = var.databricks_cli_profile != "" ? var.databricks_cli_profile : null
  host       = var.databricks_cli_profile != "" ? null : "https://accounts.gcp.databricks.com"
  account_id = var.databricks_cli_profile != "" ? null : var.databricks_account_id

  google_service_account = (var.databricks_cli_profile == "" && endswith(coalesce(var.dbx_existing_admin_account, ""), ".gserviceaccount.com")) ? var.dbx_existing_admin_account : null
}
