// EXPLANATION: All modules that reside at the workspace level

// Creates a Workspace Isolated Catalog
module "uc_catalog" {
  source = "./databricks_workspace/workspace_security_modules/uc_catalog"
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_account_id   = var.databricks_account_id
  aws_account_id          = var.aws_account_id
  resource_prefix         = var.resource_prefix
  uc_catalog_name         = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  workspace_id            = module.databricks_mws_workspace.workspace_id
  workspace_catalog_admin = var.workspace_catalog_admin

  depends_on = [
    module.databricks_mws_workspace, module.uc_assignment
  ]
}

// Create Read-Only Storage Location for Data Bucket & External Location
module "uc_external_location" {
  count  = var.enable_read_only_external_location_boolean ? 1 : 0
  source = "./databricks_workspace/workspace_security_modules/uc_external_location"
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_account_id             = var.databricks_account_id
  aws_account_id                    = var.aws_account_id
  resource_prefix                   = var.resource_prefix
  read_only_data_bucket             = var.read_only_data_bucket
  read_only_external_location_admin = var.read_only_external_location_admin

  depends_on = [
    module.databricks_mws_workspace, module.uc_assignment
  ]
}

// Workspace Admin Configuration
module "admin_configuration" {
  count  = var.enable_admin_configs_boolean ? 1 : 0
  source = "./databricks_workspace/workspace_security_modules/admin_configuration"
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
module "ip_access_list" {
  source = "./databricks_workspace/workspace_security_modules/ip_access_list"
  count  = var.enable_ip_boolean ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }

  ip_addresses = var.ip_addresses

  depends_on = [
    module.databricks_mws_workspace
  ]
}

// Create Create Cluster - Optional
module "cluster_configuration" {
  source = "./databricks_workspace/workspace_security_modules/cluster_configuration"
  count  = var.enable_cluster_boolean ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }

  compliance_security_profile_egress_ports = var.compliance_security_profile_egress_ports
  secret_config_reference                  = module.secret_management.config_reference
  resource_prefix                          = var.resource_prefix
  depends_on = [
    module.databricks_mws_workspace, module.secret_management
  ]
}

// Public Preview - System Table Schemas - Optional
module "public_preview_system_table" {
  source = "./databricks_workspace/public_preview/system_schema/"
  count  = var.enable_system_tables_schema_boolean ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [
    module.databricks_mws_workspace
  ]
}

// SAT Implementation - Optional
module "security_analysis_tool" {
  source = "./databricks_workspace/solution_accelerators/security_analysis_tool/aws"
  count  = var.enable_sat_boolean ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_url     = module.databricks_mws_workspace.workspace_url
  workspace_PAT      = module.service_principal.service_principal_id
  workspace_id       = module.databricks_mws_workspace.workspace_id
  account_console_id = var.databricks_account_id
  client_id          = var.client_id
  client_secret      = var.client_secret
  use_sp_auth        = true

  depends_on = [
    module.databricks_mws_workspace, module.service_principal
  ]
}

// System Tables Schemas - Optional
module "audit_log_alerting" {
  source = "./databricks_workspace/solution_accelerators/system_tables_audit_log/"
  count  = var.enable_audit_log_alerting ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }

  alert_emails = [var.user_workspace_admin]

  depends_on = [
    module.databricks_mws_workspace, module.uc_assignment
  ]
}