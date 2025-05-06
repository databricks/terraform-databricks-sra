# EXPLANATION: All modules that reside at the workspace level

# Creates a Workspace Isolated Catalog
module "uc_catalog" {
  source = "./databricks_workspace/workspace_security_modules/uc_catalog"
  providers = {
    databricks = databricks.created_workspace
  }

  aws_account_id                 = var.aws_account_id
  resource_prefix                = var.resource_prefix
  uc_catalog_name                = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  cmk_admin_arn                  = var.cmk_admin_arn == null ? "arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:root" : var.cmk_admin_arn
  workspace_id                   = module.databricks_mws_workspace.workspace_id
<<<<<<< Updated upstream
  user_workspace_catalog_admin   = var.user_workspace_catalog_admin
=======
  user_workspace_catalog_admin   = var.admin_user
  databricks_account_id          = var.databricks_account_id
>>>>>>> Stashed changes
  databricks_gov_shard           = var.databricks_gov_shard
  databricks_prod_aws_account_id = var.databricks_prod_aws_account_id
  uc_master_role_id              = var.uc_master_role_id

  depends_on = [module.databricks_mws_workspace, module.uc_assignment]
}

<<<<<<< Updated upstream
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
  databricks_gov_shard              = var.databricks_gov_shard
  databricks_prod_aws_account_id    = var.databricks_prod_aws_account_id
  uc_master_role_id                 = var.uc_master_role_id
}

// Workspace Admin Configuration
module "admin_configuration" {
  count  = var.enable_admin_configs_boolean ? 1 : 0
  source = "./databricks_workspace/workspace_security_modules/admin_configuration"
  providers = {
    databricks = databricks.created_workspace
  }
}

// IP Access Lists - Optional
module "ip_access_list" {
  source = "./databricks_workspace/workspace_security_modules/ip_access_list"
  count  = var.enable_ip_boolean ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }

  ip_addresses = var.ip_addresses
}

// Create Create Cluster - Optional
module "cluster_configuration" {
  source = "./databricks_workspace/workspace_security_modules/cluster_configuration"
  count  = var.enable_cluster_boolean ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }

  compliance_security_profile_egress_ports = var.compliance_security_profile_egress_ports
  resource_prefix                          = var.resource_prefix
  operation_mode                           = var.operation_mode
}

// System Table Schemas Enablement - Optional
=======
# System Table Schemas Enablement - Coming Soon to AWS-Gov
/*
>>>>>>> Stashed changes
module "system_table" {
  source = "./databricks_workspace/workspace_security_modules/system_schema/"
  count  = var.enable_system_tables_schema_boolean ? 1 : 0
  providers = {
    databricks = databricks.created_workspace
  }
  depends_on = [ module.uc_assignment ]
}

<<<<<<< Updated upstream
// SAT Implementation - Optional
module "security_analysis_tool" {
  source = "./databricks_workspace/solution_accelerators/security_analysis_tool/aws"
  count  = var.enable_sat_boolean ? 1 : 0
=======
# Create Create Cluster
module "cluster_configuration" {
  source = "./databricks_workspace/classic_cluster"
>>>>>>> Stashed changes
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_url       = module.databricks_mws_workspace.workspace_url
  workspace_id         = module.databricks_mws_workspace.workspace_id
  account_console_id   = var.databricks_account_id
  client_id            = var.client_id
  client_secret        = var.client_secret
  use_sp_auth          = true
  proxies              = {}
  analysis_schema_name = "SAT"

  depends_on = [
    module.databricks_mws_workspace
  ]
}

<<<<<<< Updated upstream
// System Tables Schemas - Optional
module "audit_log_alerting" {
  source = "./databricks_workspace/solution_accelerators/system_tables_audit_log/"
  count  = var.enable_audit_log_alerting ? 1 : 0
=======
# Restrictive DBFS bucket policy
module "restrictive_root_bucket" {
  source = "./databricks_workspace/restrictive_root_bucket"
>>>>>>> Stashed changes
  providers = {
    databricks = databricks.created_workspace
  }

  alert_emails = [var.user_workspace_admin]
}