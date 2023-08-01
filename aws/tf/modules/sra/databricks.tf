// Billable Usage and Audit Logs
module "log_delivery" {
    source = "./databricks/logging_configuration"
    providers = {
      databricks = databricks.mws
    }
  
  databricks_account_id    = var.databricks_account_id
  resource_prefix          = var.resource_prefix
}

// Create Databricks Workspace
module "databricks_mws_workspace" {
  source = "./databricks/databricks_workspace"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id        = var.databricks_account_id
  resource_prefix              = var.resource_prefix
  security_group_ids           = [aws_security_group.sg.id]
  subnet_ids                   = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  vpc_id                       = module.vpc.vpc_id
  cross_account_role_arn       = aws_iam_role.cross_account_role.arn
  bucket_name                  = aws_s3_bucket.root_storage_bucket.id
  region                       = var.region
  backend_rest                 = aws_vpc_endpoint.backend_rest.id
  backend_relay                = aws_vpc_endpoint.backend_relay.id
  managed_storage_key          = aws_kms_key.managed_storage.arn
  workspace_storage_key        = aws_kms_key.workspace_storage.arn
  managed_storage_key_alias    = aws_kms_alias.managed_storage_key_alias.name
  workspace_storage_key_alias  = aws_kms_alias.workspace_storage_key_alias.name
}

// Create Unity Catalog and Assignment to Databricks Workspace
module "databricks_uc" {
    source = "./databricks/unity_catalog"
    providers = {
      databricks = databricks.created_workspace
    }
  
  resource_prefix                 = var.resource_prefix
  databricks_workspace            = module.databricks_mws_workspace.workspace_id
  uc_s3                           = aws_s3_bucket.unity_catalog_bucket.id
  uc_iam_arn                      = aws_iam_role.unity_catalog_role.arn
  uc_iam_name                     = aws_iam_role.unity_catalog_role.name
  data_bucket                     = var.data_bucket
  data_access                     = var.data_access
  storage_credential_role_name    = aws_iam_role.storage_credential_role.name
  storage_credential_role_arn     = aws_iam_role.storage_credential_role.arn
  depends_on = [
    module.databricks_mws_workspace
    ]
}

// Workspace Admin Configuration
module "admin_configuration" {
    source = "./databricks/admin_configuration"
    providers = {
      databricks = databricks.created_workspace
    }
  
  depends_on = [
    module.databricks_mws_workspace
    ]
}

// Service Principal
module "service_principal" {
    source = "./databricks/service_principal"
    providers = {
      databricks = databricks.created_workspace
    }
  
  depends_on = [
    module.databricks_mws_workspace
    ]
}

// Token Management
module "token_management" {
    source = "./databricks/token_management"
    providers = {
      databricks = databricks.created_workspace
    }
  
  depends_on = [
    module.databricks_mws_workspace
    ]
}

// Secret Management
module "secret_management" {
    source = "./databricks/secret_management"
    providers = {
      databricks = databricks.created_workspace
    }
  
  depends_on = [
    module.databricks_mws_workspace
    ]
}

// IP Access Lists
# module "ip_access_list" {
#     source = "./databricks/ip_access_list"
#     providers = {
#       databricks = databricks.created_workspace
#     }

#   ip_addresses = var.ip_addresses
  
#   depends_on = [
#     module.databricks_mws_workspace
#     ]
# }

// SAT Implementation - Optional
# module "security_analysis_tool" {
#     source = "./databricks/security_analysis_tool/aws"
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

// Create Create Cluster - Optional
# module "cluster_configuration" {
#     source = "./modules/cluster_configuration"
#     providers = {
#       databricks = databricks.created_workspace
#     }
  
#   secret_config_reference   = module.secret_management.config_reference
#   resource_prefix           = var.resource_prefix
#   depends_on                = [
#     module.databricks_mws_workspace, module.secret_management
#     ]
# }