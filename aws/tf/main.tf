# =============================================================================
# Databricks Account Modules
# =============================================================================

# Create Unity Catalog Metastore
module "unity_catalog_metastore_creation" {
  source = "./modules/databricks_account/unity_catalog_metastore_creation"
  providers = {
    databricks = databricks.mws
  }

  region                = var.region
  metastore_exists      = var.metastore_exists
  custom_metastore_name = var.custom_metastore_name
}

# Create Network Connectivity Connection Object
module "network_connectivity_configuration" {
  source = "./modules/databricks_account/network_connectivity_configuration"
  providers = {
    databricks = databricks.mws
  }

  private_endpoint_rules = var.serverless_private_endpoint_rules
  region                 = var.region
  resource_prefix        = var.resource_prefix
}

# Create a Network Policy
module "network_policy" {
  source = "./modules/databricks_account/network_policy"
  providers = {
    databricks = databricks.mws
  }

  context_based_ingress_ip_acl  = var.context_based_ingress_ip_acl
  databricks_account_id         = var.databricks_account_id
  enable_security_analysis_tool = var.enable_security_analysis_tool
  resource_prefix               = var.resource_prefix
}

# Disable legacy features like Hive Metastore, DBFS, and no-isolation shared clusters for newly created workspaces at the account level.
# NOTE: This affects ALL new workspaces created in the Databricks account, not just this deployment.
module "disable_legacy_features" {
  count  = var.disable_legacy_features_at_account_level ? 1 : 0
  source = "./modules/databricks_account/disable_legacy_features"
  providers = {
    databricks = databricks.mws
  }
}

# Create Databricks Workspace
module "databricks_mws_workspace" {
  source = "./modules/databricks_account/workspace"

  providers = {
    databricks = databricks.mws
  }

  # Basic Configuration
  databricks_account_id  = var.databricks_account_id
  resource_prefix        = var.resource_prefix
  region                 = var.region
  deployment_name        = var.deployment_name
  workspace_display_name = var.workspace_display_name
  compute_mode           = var.compute_mode

  # Network Configuration (skipped for serverless-only workspaces)
  vpc_id                            = local.is_serverless ? null : (var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id)
  subnet_ids                        = local.is_serverless ? null : (var.custom_private_subnet_ids != null ? var.custom_private_subnet_ids : module.vpc[0].private_subnets)
  security_group_ids                = local.is_serverless ? null : (var.custom_sg_id != null ? [var.custom_sg_id] : [aws_security_group.sg[0].id])
  general_access                    = local.is_serverless || var.custom_general_access_mws_vpce_id != null ? null : (var.custom_general_access_vpce_id != null ? var.custom_general_access_vpce_id : aws_vpc_endpoint.general_access[0].id)
  general_access_mws_vpce_id        = var.custom_general_access_mws_vpce_id
  scc_tunnel_dataplane_relay_access = local.is_serverless || var.custom_scc_relay_mws_vpce_id != null ? null : (var.custom_scc_relay_vpce_id != null ? var.custom_scc_relay_vpce_id : aws_vpc_endpoint.scc_tunnel_dataplane_relay_access[0].id)
  scc_relay_mws_vpce_id             = var.custom_scc_relay_mws_vpce_id
  service_direct                    = local.is_serverless || var.custom_service_direct_mws_vpce_id != null ? [] : (var.custom_service_direct_vpce_id != null ? [var.custom_service_direct_vpce_id] : aws_vpc_endpoint.service_direct[*].id)
  service_direct_enabled            = local.service_direct_enabled
  service_direct_mws_vpce_id        = var.custom_service_direct_mws_vpce_id

  # Cross-Account Role (skipped for serverless-only workspaces)
  cross_account_role_arn = local.is_serverless ? null : aws_iam_role.cross_account_role[0].arn

  # Root Storage Bucket (skipped for serverless-only workspaces)
  bucket_name = local.is_serverless ? null : aws_s3_bucket.root_storage_bucket[0].id

  # KMS Keys (skipped for serverless-only workspaces)
  managed_services_key        = local.is_serverless ? null : aws_kms_key.managed_services[0].arn
  workspace_storage_key       = local.is_serverless ? null : aws_kms_key.workspace_storage[0].arn
  managed_services_key_alias  = local.is_serverless ? null : aws_kms_alias.managed_services_key_alias[0].name
  workspace_storage_key_alias = local.is_serverless ? null : aws_kms_alias.workspace_storage_key_alias[0].name

  # Network Connectivity Configuration and Network Policy
  network_connectivity_configuration_id = module.network_connectivity_configuration.ncc_id
  network_policy_id                     = module.network_policy.network_policy_id

  depends_on = [module.unity_catalog_metastore_creation, module.network_connectivity_configuration, module.network_policy, module.disable_legacy_features]
}

# Wait for the newly created workspace to become fully available. Workspace-level settings applied
# immediately after creation can intermittently fail to find the workspace by its ID.
resource "time_sleep" "wait_for_workspace" {
  create_duration = "60s"

  depends_on = [module.databricks_mws_workspace]
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

# Audit Log Delivery (skipped for serverless-only workspaces, which have no customer S3 bucket;
# monitor audit events via system tables instead - see the system_tables_audit_log customization)
module "log_delivery" {
  count  = var.audit_log_delivery_exists || local.is_serverless ? 0 : 1
  source = "./modules/databricks_account/audit_log_delivery"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
  aws_assume_partition  = local.assume_role_partition
}

# =============================================================================
# Databricks Workspace Modules
# =============================================================================

# Creates a Workspace Isolated Catalog (skipped for serverless-only workspaces, which use the
# auto-created workspace catalog backed by Databricks default storage)
module "unity_catalog_catalog_creation" {
  count  = local.is_serverless ? 0 : 1
  source = "./modules/databricks_workspace/unity_catalog_catalog_creation"
  providers = {
    databricks = databricks.created_workspace
  }

  aws_account_id               = var.aws_account_id
  aws_iam_partition            = local.computed_aws_partition
  aws_assume_partition         = local.assume_role_partition
  unity_catalog_iam_arn        = local.unity_catalog_iam_arn
  resource_prefix              = var.resource_prefix
  uc_catalog_name              = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  cmk_admin_arn                = local.cmk_admin_value
  workspace_id                 = module.databricks_mws_workspace.workspace_id
  user_workspace_catalog_admin = var.admin_user

  depends_on = [module.unity_catalog_metastore_assignment]
}

# Restrictive Root Buckt Policy
module "restrictive_root_bucket" {
  count  = local.is_serverless ? 0 : 1
  source = "./modules/databricks_workspace/restrictive_root_bucket"
  providers = {
    aws = aws
  }

  databricks_account_id     = var.databricks_account_id
  databricks_aws_account_id = local.databricks_aws_account_id
  aws_partition             = local.computed_aws_partition
  workspace_id              = module.databricks_mws_workspace.workspace_id
  region_name               = var.databricks_gov_shard == "dod" ? var.region_name_config[var.region].secondary_name : var.region_name_config[var.region].primary_name
  root_s3_bucket            = "${var.resource_prefix}-workspace-root-storage"
}

# Disable legacy settings like Hive Metastore, Disables Databricks Runtime prior to 13.3 LTS, DBFS, DBFS Mounts,etc.
module "disable_legacy_settings" {
  source = "./modules/databricks_workspace/disable_legacy_settings"
  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [time_sleep.wait_for_workspace]
}

# Enable Automatic Cluster Update on the Databricks Workspace.
# NOTE: Automatic cluster update is automatically enabled when the compliance security profile is enabled.
module "automatic_cluster_update" {
  count  = var.enable_automatic_cluster_update ? 1 : 0
  source = "./modules/databricks_workspace/automatic_cluster_update"

  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [time_sleep.wait_for_workspace]
}

# Enable Enhanced Security Monitoring (ESM) on the Databricks Workspace.
# NOTE: ESM is automatically enabled when the compliance security profile is enabled.
module "enhanced_security_monitoring" {
  count  = var.enable_enhanced_security_monitoring ? 1 : 0
  source = "./modules/databricks_workspace/enhanced_security_monitoring"

  providers = {
    databricks = databricks.created_workspace
  }

  depends_on = [time_sleep.wait_for_workspace]
}

# Enable Compliance Security Profile (CSP) on the Databricks Workspace.
module "compliance_security_profile" {
  count  = var.enable_compliance_security_profile ? 1 : 0
  source = "./modules/databricks_workspace/compliance_security_profile"

  providers = {
    databricks = databricks.created_workspace
  }

  compliance_standards = var.compliance_standards

  depends_on = [time_sleep.wait_for_workspace]
}

# Create Cluster (skipped for serverless-only workspaces)
module "cluster_configuration" {
  count  = local.is_serverless ? 0 : 1
  source = "./modules/databricks_workspace/classic_cluster"
  providers = {
    databricks = databricks.created_workspace
  }

  enable_compliance_security_profile = var.enable_compliance_security_profile
  resource_prefix                    = var.resource_prefix
  region                             = var.region

  depends_on = [module.databricks_mws_workspace]
}

# =============================================================================
# Security Analysis Tool  - review the documentation for more information on the configuration as network egress is required for certain SAT functionality and features.
# https://databricks-industry-solutions.github.io/security-analysis-tool/
# =============================================================================

module "security_analysis_tool" {
  count  = var.enable_security_analysis_tool && var.region != "us-gov-west-1" ? 1 : 0
  source = "./modules/security_analysis_tool"

  providers = {
    databricks = databricks.created_workspace
  }

  # Authentication Variables
  databricks_account_id = var.databricks_account_id
  client_id             = null # Provide Workspace Admin ID
  client_secret         = null # Provide Workspace Admin Secret

  use_sp_auth = true

  # Databricks Variables
  # For serverless-only workspaces, SAT uses the auto-created workspace catalog (named after the workspace).
  analysis_schema_name = replace(local.is_serverless ? "${coalesce(var.workspace_display_name, var.resource_prefix)}.SAT" : "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}.SAT", "-", "_")
  workspace_id         = module.databricks_mws_workspace.workspace_id

  # Configuration Variables
  proxies                         = {}
  run_on_serverless               = true #if set to true, all SAT workflows will run on serverless compute.
  sql_warehouse_enable_serverless = true #if set to true, the SAT SQL Warehouse will be enabled on serverless compute and is used by the SAT dashboard

  depends_on = [module.unity_catalog_catalog_creation]
}


# =============================================================================
# State Moves
# =============================================================================

# Preserve state across count addition for the serverless workspace variant
moved {
  from = module.restrictive_root_bucket
  to   = module.restrictive_root_bucket[0]
}

moved {
  from = module.cluster_configuration
  to   = module.cluster_configuration[0]
}

moved {
  from = module.unity_catalog_catalog_creation
  to   = module.unity_catalog_catalog_creation[0]
}
