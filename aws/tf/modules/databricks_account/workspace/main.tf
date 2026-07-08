# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces


locals {
  # Serverless-only workspaces are created without credentials, storage, network,
  # private access settings, or customer-managed key configurations
  is_serverless = var.compute_mode == "SERVERLESS"
}

# Wait on Credential Due to Race Condition
# https://kb.databricks.com/en_US/terraform/failed-credential-validation-checks-error-with-terraform 
resource "null_resource" "previous" {
  count = local.is_serverless ? 0 : 1
}

resource "time_sleep" "wait_30_seconds" {
  count      = local.is_serverless ? 0 : 1
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

# Credential Configuration
resource "databricks_mws_credentials" "this" {
  count            = local.is_serverless ? 0 : 1
  role_arn         = var.cross_account_role_arn
  credentials_name = "${var.resource_prefix}-credentials"
  depends_on       = [time_sleep.wait_30_seconds]
}

# Storage Configuration
resource "databricks_mws_storage_configurations" "this" {
  count                      = local.is_serverless ? 0 : 1
  account_id                 = var.databricks_account_id
  bucket_name                = var.bucket_name
  storage_configuration_name = "${var.resource_prefix}-storage"
}

# Preserve state across rename and count addition: backend_rest -> general_access[0], backend_relay -> scc_tunnel_dataplane_relay_access[0]
moved {
  from = databricks_mws_vpc_endpoint.backend_rest
  to   = databricks_mws_vpc_endpoint.general_access[0]
}

moved {
  from = databricks_mws_vpc_endpoint.backend_relay
  to   = databricks_mws_vpc_endpoint.scc_tunnel_dataplane_relay_access[0]
}

# General Access VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "general_access" {
  count               = var.general_access_mws_vpce_id == null && !local.is_serverless ? 1 : 0
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = var.general_access
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-general-access-${var.vpc_id}"
  region              = var.region
}

# SCC Tunnel Dataplane Relay Access VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "scc_tunnel_dataplane_relay_access" {
  count               = var.scc_relay_mws_vpce_id == null && !local.is_serverless ? 1 : 0
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = var.scc_tunnel_dataplane_relay_access
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-dataplane-relay-access-${var.vpc_id}"
  region              = var.region
}

# Service Direct VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "service_direct" {
  count               = var.service_direct_mws_vpce_id == null && length(var.service_direct) > 0 && !local.is_serverless ? 1 : 0
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = var.service_direct[0]
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-service-direct-${var.vpc_id}"
  region              = var.region
}

# Network Configuration
resource "databricks_mws_networks" "this" {
  count              = local.is_serverless ? 0 : 1
  account_id         = var.databricks_account_id
  network_name       = "${var.resource_prefix}-network"
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
  vpc_endpoints {
    dataplane_relay = [var.scc_relay_mws_vpce_id != null ? var.scc_relay_mws_vpce_id : databricks_mws_vpc_endpoint.scc_tunnel_dataplane_relay_access[0].vpc_endpoint_id]
    rest_api        = [var.general_access_mws_vpce_id != null ? var.general_access_mws_vpce_id : databricks_mws_vpc_endpoint.general_access[0].vpc_endpoint_id]
  }
}

# Managed Services Key Configuration
resource "databricks_mws_customer_managed_keys" "managed_services" {
  count      = local.is_serverless ? 0 : 1
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = var.managed_services_key
    key_alias = var.managed_services_key_alias
  }
  use_cases = ["MANAGED_SERVICES"]
}

# Workspace Storage Key Configuration
resource "databricks_mws_customer_managed_keys" "workspace_storage" {
  count      = local.is_serverless ? 0 : 1
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = var.workspace_storage_key
    key_alias = var.workspace_storage_key_alias
  }
  use_cases = ["STORAGE"]
}

# Private Access Setting Configuration
resource "databricks_mws_private_access_settings" "pas" {
  count                        = local.is_serverless ? 0 : 1
  private_access_settings_name = "${var.resource_prefix}-PAS"
  region                       = var.region
  public_access_enabled        = true
  private_access_level         = "ACCOUNT"
}

# Workspace Configuration with Deployment Name
resource "databricks_mws_workspaces" "workspace" {
  account_id                               = var.databricks_account_id
  aws_region                               = var.region
  workspace_name                           = coalesce(var.workspace_display_name, var.resource_prefix)
  deployment_name                          = var.deployment_name
  compute_mode                             = local.is_serverless ? "SERVERLESS" : null
  credentials_id                           = local.is_serverless ? null : databricks_mws_credentials.this[0].credentials_id
  storage_configuration_id                 = local.is_serverless ? null : databricks_mws_storage_configurations.this[0].storage_configuration_id
  network_id                               = local.is_serverless ? null : databricks_mws_networks.this[0].network_id
  private_access_settings_id               = local.is_serverless ? null : databricks_mws_private_access_settings.pas[0].private_access_settings_id
  managed_services_customer_managed_key_id = local.is_serverless ? null : databricks_mws_customer_managed_keys.managed_services[0].customer_managed_key_id
  storage_customer_managed_key_id          = local.is_serverless ? null : databricks_mws_customer_managed_keys.workspace_storage[0].customer_managed_key_id
  pricing_tier                             = "ENTERPRISE"

  lifecycle {
    precondition {
      condition     = !(local.is_serverless && var.region == "us-gov-west-1")
      error_message = "compute_mode SERVERLESS is not supported in GovCloud (us-gov-west-1); serverless workspaces are not currently available there. Use compute_mode HYBRID."
    }
  }

  depends_on = [databricks_mws_networks.this]
}

# Attach the Network Policy
resource "databricks_workspace_network_option" "workspace_assignment" {
  network_policy_id = var.network_policy_id
  workspace_id      = databricks_mws_workspaces.workspace.workspace_id
}

# Attach the Network Connectivity Configuration Object
resource "databricks_mws_ncc_binding" "ncc_binding" {
  network_connectivity_config_id = var.network_connectivity_configuration_id
  workspace_id                   = databricks_mws_workspaces.workspace.workspace_id
}
# Preserve state across count addition for the serverless workspace variant
moved {
  from = null_resource.previous
  to   = null_resource.previous[0]
}

moved {
  from = time_sleep.wait_30_seconds
  to   = time_sleep.wait_30_seconds[0]
}

moved {
  from = databricks_mws_credentials.this
  to   = databricks_mws_credentials.this[0]
}

moved {
  from = databricks_mws_storage_configurations.this
  to   = databricks_mws_storage_configurations.this[0]
}

moved {
  from = databricks_mws_networks.this
  to   = databricks_mws_networks.this[0]
}

moved {
  from = databricks_mws_customer_managed_keys.managed_services
  to   = databricks_mws_customer_managed_keys.managed_services[0]
}

moved {
  from = databricks_mws_customer_managed_keys.workspace_storage
  to   = databricks_mws_customer_managed_keys.workspace_storage[0]
}

moved {
  from = databricks_mws_private_access_settings.pas
  to   = databricks_mws_private_access_settings.pas[0]
}
