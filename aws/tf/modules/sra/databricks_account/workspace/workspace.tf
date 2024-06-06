// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces


// Wait on Credential Due to Race Condition
// https://kb.databricks.com/en_US/terraform/failed-credential-validation-checks-error-with-terraform 
resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

// Credential Configuration
resource "databricks_mws_credentials" "this" {
  role_arn         = var.cross_account_role_arn
  credentials_name = "${var.resource_prefix}-credentials"
  depends_on       = [time_sleep.wait_30_seconds]
}

// Storage Configuration
resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  bucket_name                = var.bucket_name
  storage_configuration_name = "${var.resource_prefix}-storage"
}

// Backend REST VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "backend_rest" {
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = var.backend_rest
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-backend-${var.vpc_id}"
  region              = var.region
}

// Backend Rest VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "backend_relay" {
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = var.backend_relay
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-relay-${var.vpc_id}"
  region              = var.region
}

// Network Configuration
resource "databricks_mws_networks" "this" {
  account_id         = var.databricks_account_id
  network_name       = "${var.resource_prefix}-network"
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
  vpc_endpoints {
    dataplane_relay = [databricks_mws_vpc_endpoint.backend_relay.vpc_endpoint_id]
    rest_api        = [databricks_mws_vpc_endpoint.backend_rest.vpc_endpoint_id]
  }
}

// Managed Key Configuration
resource "databricks_mws_customer_managed_keys" "managed_storage" {
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = var.managed_storage_key
    key_alias = var.managed_storage_key_alias
  }
  use_cases = ["MANAGED_SERVICES"]
}

// Workspace Storage Key Configuration
resource "databricks_mws_customer_managed_keys" "workspace_storage" {
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = var.workspace_storage_key
    key_alias = var.workspace_storage_key_alias
  }
  use_cases = ["STORAGE"]
}

// Private Access Setting Configuration
resource "databricks_mws_private_access_settings" "pas" {
  private_access_settings_name = "${var.resource_prefix}-PAS"
  region                       = var.region
  public_access_enabled        = true
  private_access_level         = "ACCOUNT"
}

// Workspace Configuration
resource "databricks_mws_workspaces" "this" {
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = var.resource_prefix
  # deployment_name                          = "development-company-A" // Deployment name for the workspace URL. This is not enabled by default on an account. Please reach out to your Databricks representative for more information.
  credentials_id                           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id                 = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id                               = databricks_mws_networks.this.network_id
  private_access_settings_id               = databricks_mws_private_access_settings.pas.private_access_settings_id
  managed_services_customer_managed_key_id = databricks_mws_customer_managed_keys.managed_storage.customer_managed_key_id
  storage_customer_managed_key_id          = databricks_mws_customer_managed_keys.workspace_storage.customer_managed_key_id
  pricing_tier                             = "ENTERPRISE"
  depends_on                               = [databricks_mws_networks.this]
}