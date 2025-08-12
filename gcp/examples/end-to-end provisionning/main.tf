
module "service_account" {
  source = "../../modules/service_account/"
  # Bare Minimum Variables
  project = var.google_project
  sa_name = var.sa_name
  create_service_account_key = true
  delegate_from = var.delegate_from
}



module "make_sa_dbx_admin" {
  source = "../../modules/make_sa_dbx_admin/"
  
  databricks_account_id = var.databricks_account_id
  new_admin_account = module.service_account.workspace_creator_email  # Use output from service_account module
  dbx_existing_admin_account = data.google_client_openid_userinfo.me.email  # Use the current user's email as the existing admin account
}

module "customer_managed_vpc" {
  source                      = "../../modules/workspace_deployment/"
  
  # Bare Minimum Variables
  google_project               = var.google_project
  google_region                = var.google_region
  databricks_account_id        = var.databricks_account_id
  databricks_google_service_account = module.service_account.workspace_creator_email  # Use output from service_account module
  workspace_name               = var.workspace_name
  databricks_google_service_account_key = module.service_account.workspace_creator_key  # Use output from service_account module
  regional_metastore_id = var.regional_metastore_id
  can_create_workspaces = module.service_account.workspace_creator_role_applied 

  admin_user_email            = module.make_sa_dbx_admin.original_admin_account

  # Flags
  use_existing_vpc             = false
  use_existing_pas             = false
  use_existing_PSC_EP          = false
  use_existing_cmek            = false
  use_psc                      = false
  harden_network               = true
  provision_regional_metastore  = false 
  
}

