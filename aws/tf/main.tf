# =============================================================================
# Databricks Account Modules
# =============================================================================

# Create Unity Catalog Metastore
module "unity_catalog_metastore_creation" {
  source = "./modules/databricks_account/unity_catalog_metastore_creation"
  providers = {
    databricks = databricks.mws
  }

  resource_prefix  = var.resource_prefix
  region           = var.region
  metastore_exists = var.metastore_exists
}

# Create Network Connectivity Connection Object
module "network_connectivity_configuration" {
  source = "./modules/databricks_account/network_connectivity_configuration"
  providers = {
    databricks = databricks.mws
  }

  region          = var.region
  resource_prefix = var.resource_prefix
}

# Create a Network Policy
module "network_policy" {
  source = "./modules/databricks_account/network_policy"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id = var.databricks_account_id
  region                = var.region
  resource_prefix       = var.resource_prefix
}

# Create Databricks Workspace
module "databricks_mws_workspace" {
  source = "./modules/databricks_account/workspace"

  providers = {
    databricks = databricks.mws
  }

  # Basic Configuration
  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
  region                = var.region
  deployment_name       = var.deployment_name

  # Network Configuration
  vpc_id             = var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id
  subnet_ids         = var.custom_private_subnet_ids != null ? var.custom_private_subnet_ids : module.vpc[0].private_subnets
  security_group_ids = var.custom_sg_id != null ? [var.custom_sg_id] : [aws_security_group.sg[0].id]
  backend_rest       = var.custom_workspace_vpce_id != null ? var.custom_workspace_vpce_id : aws_vpc_endpoint.backend_rest[0].id
  backend_relay      = var.custom_relay_vpce_id != null ? var.custom_relay_vpce_id : aws_vpc_endpoint.backend_relay[0].id

  # Cross-Account Role
  cross_account_role_arn = aws_iam_role.cross_account_role.arn

  # Root Storage Bucket
  bucket_name = aws_s3_bucket.root_storage_bucket.id

  # KMS Keys
  managed_services_key        = aws_kms_key.managed_services.arn
  workspace_storage_key       = aws_kms_key.workspace_storage.arn
  managed_services_key_alias  = aws_kms_alias.managed_services_key_alias.name
  workspace_storage_key_alias = aws_kms_alias.workspace_storage_key_alias.name

  # Network Connectivity Configuration and Network Policy
  network_connectivity_configuration_id = module.network_connectivity_configuration.ncc_id
  network_policy_id                     = module.network_policy.network_policy_id

  depends_on = [module.unity_catalog_metastore_creation, module.network_connectivity_configuration, module.network_policy]
}

# Unity Catalog Assignment
module "unity_catalog_metastore_assignment" {
  source = "./modules/databricks_account/unity_catalog_metastore_assignment"
  providers = {
    databricks = databricks.mws
  }

  metastore_id = module.unity_catalog_metastore_creation.metastore_id
  workspace_id = module.databricks_mws_workspace.workspace_id

  depends_on = [module.unity_catalog_metastore_creation, module.databricks_mws_workspace]
}

# User Workspace Assignment (Admin)
module "user_assignment" {
  source = "./modules/databricks_account/user_assignment"
  providers = {
    databricks = databricks.mws
  }

  workspace_id     = module.databricks_mws_workspace.workspace_id
  workspace_access = var.admin_user

  depends_on = [module.unity_catalog_metastore_assignment, module.databricks_mws_workspace]
}

# Audit Log Delivery
module "log_delivery" {
  count  = var.audit_log_delivery_exists ? 0 : 1
  source = "./modules/databricks_account/audit_log_delivery"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
}

# =============================================================================
# Databricks Workspace Modules
# =============================================================================

# Creates a Workspace Isolated Catalog
module "unity_catalog_catalog_creation" {
  source = "./modules/databricks_workspace/unity_catalog_catalog_creation"
  providers = {
    databricks = databricks.created_workspace
  }

  aws_account_id               = var.aws_account_id
  resource_prefix              = var.resource_prefix
  uc_catalog_name              = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  cmk_admin_arn                = var.cmk_admin_arn == null ? "arn:aws:iam::${var.aws_account_id}:root" : var.cmk_admin_arn
  workspace_id                 = module.databricks_mws_workspace.workspace_id
  user_workspace_catalog_admin = var.admin_user

  depends_on = [module.unity_catalog_metastore_assignment]
}

# System Table Schemas Enablement
module "system_table" {
  source = "./modules/databricks_workspace/system_schema"
  providers = {
    databricks = databricks.created_workspace
  }
  depends_on = [module.unity_catalog_metastore_assignment]
}

# Create Create Cluster
module "cluster_configuration" {
  source = "./modules/databricks_workspace/classic_cluster"
  providers = {
    databricks = databricks.created_workspace
  }

  resource_prefix = var.resource_prefix
  depends_on      = [module.databricks_mws_workspace]
}

# Restrictive Root Buckt Policy
module "restrictive_root_bucket" {
  source = "./modules/databricks_workspace/restrictive_root_bucket"
  providers = {
    aws = aws
  }

  databricks_account_id = var.databricks_account_id
  workspace_id          = module.databricks_mws_workspace.workspace_id
  region_name           = var.region_name[var.region]
  root_s3_bucket        = "${var.resource_prefix}-workspace-root-storage"
}

# Disable legacy access settings like Hive Metastore, Disables Databricks Runtime prior to 13.3 LTS, etc.
module "disable_legacy_access_setting" {
  source = "./modules/databricks_workspace/disable_legacy_access_settings"
  providers = {
    databricks = databricks.created_workspace
  }
}

# =============================================================================
# Security Analysis Tool  - PyPI must be enabled in network policy resource to function.
# =============================================================================

module "security_analysis_tool" {
  count  = var.enable_security_analysis_tool ? 1 : 0
  source = "./modules/security_analysis_tool"

  providers = {
    databricks = databricks.created_workspace
  }

  # Authentication Variables
  account_console_id    = var.databricks_account_id
  client_id             = null # Provide Workspace Admin ID
  client_secret         = null # Provide Workspace Admin Secret
  databricks_account_id = var.databricks_account_id
  use_sp_auth           = true

  # Databricks Variables
  analysis_schema_name = replace("${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}.SAT", "-", "_")
  catalog_name         = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  schema_name          = replace("${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}.SAT", "-", "_")
  workspace_id         = module.databricks_mws_workspace.workspace_id

  # Configuration Variables
  proxies           = {}
  run_on_serverless = true

  depends_on = [module.unity_catalog_catalog_creation]
}