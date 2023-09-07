// EXPLANATION: All modules that reside at the workspace level

// Create Read-Only Storage Location for Data Bucket & External Location
module "uc_storage" {
  source = "./databricks_workspace/workspace_security_modules/uc_storage"
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_account_id = var.databricks_account_id
  aws_account_id        = var.aws_account_id
  resource_prefix       = var.resource_prefix
  data_bucket           = var.data_bucket
  data_access           = var.data_access

  depends_on = [
    module.databricks_mws_workspace, module.uc_assignment
  ]
}

// Workspace Admin Configuration
module "admin_configuration" {
  source = "./databricks_workspace/workspace_security_modules/admin_configuration"
  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [
    module.databricks_mws_workspace
  ]
}

// Service Principal
module "service_principal" {
  source = "./databricks_workspace/workspace_security_modules/service_principal"
  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [
    module.databricks_mws_workspace
  ]
}

// Token Management
module "token_management" {
  source = "./databricks_workspace/workspace_security_modules/token_management"
  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [
    module.databricks_mws_workspace
  ]
}

// Secret Management
module "secret_management" {
  source = "./databricks_workspace/workspace_security_modules/secret_management"
  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [
    module.databricks_mws_workspace
  ]
}

// IP Access Lists - Optional
# module "ip_access_list" {
#     source = "./databricks_workspace/workspace_security_modules/ip_access_list"
#     providers = {
#       databricks = databricks.created_workspace
#     }

#   ip_addresses = var.ip_addresses

#   depends_on = [
#     module.databricks_mws_workspace
#     ]
# }

// Create Create Cluster - Optional
# module "cluster_configuration" {
#     source = "./databricks_workspace/workspace_security_modules/cluster_configuration"
#     providers = {
#       databricks = databricks.created_workspace
#     }

#   secret_config_reference   = module.secret_management.config_reference
#   resource_prefix           = var.resource_prefix
#   depends_on                = [
#     module.databricks_mws_workspace, module.secret_management
#     ]
# }

// SAT Implementation - Optional
# module "security_analysis_tool" {
#     source = "./databricks_workspace/security_analysis_tool/aws"
#     providers = {
#       databricks = databricks.created_workspace
#     }

#   databricks_url     = module.databricks_mws_workspace.workspace_url
#   workspace_PAT      = module.service_principal.service_principal_id
#   workspace_id       = module.databricks_mws_workspace.workspace_id
#   account_console_id = var.databricks_account_id
#   account_user       = var.databricks_account_username
#   account_pass       = var.databricks_account_password

#   depends_on                = [
#     module.databricks_mws_workspace, module.service_principal
#     ]
# }