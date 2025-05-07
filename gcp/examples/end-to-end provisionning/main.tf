module "customer_managed_vpc" {
  source                      = "../../modules/workspace_deployment/"
  
  # Bare Minimum Variables
  google_project               = var.google_project
  google_region                = var.google_region
  databricks_account_id        = var.databricks_account_id
  databricks_google_service_account = var.databricks_google_service_account
  workspace_name               = var.workspace_name

  # Flags
  use_existing_vpc             = false
  use_existing_pas             = false
  use_existing_PSC_EP          = false
  use_existing_cmek            = false
  harden_network               = true
  
}