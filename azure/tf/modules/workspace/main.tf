locals {
  dbfs_name       = join("", ["dbstorage", random_string.dbfsnaming.result])
  managed_rg_name = join("", [module.naming.resource_group.name_unique, "adbmanaged"])
  public_subnet   = provider::azurerm::parse_resource_id(var.network_configuration.public_subnet_id)
  private_subnet  = provider::azurerm::parse_resource_id(var.network_configuration.private_subnet_id)
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

resource "random_string" "dbfsnaming" {
  special = false
  upper   = false
  length  = 13
}

# Define an Azure Databricks workspace resource
resource "azurerm_databricks_workspace" "this" {
  name                        = lookup(var.name_overrides, "databricks_workspace", module.naming.databricks_workspace.name)
  resource_group_name         = var.resource_group_name
  managed_resource_group_name = local.managed_rg_name
  location                    = var.location
  sku                         = "premium"

  # managed_disk_cmk_rotation_to_latest_version_enabled = var.is_kms_enabled ? true : false
  managed_disk_cmk_key_vault_key_id     = var.is_kms_enabled ? var.managed_disk_key_id : null
  managed_services_cmk_key_vault_key_id = var.is_kms_enabled ? var.managed_services_key_id : null
  customer_managed_key_enabled          = var.is_kms_enabled
  infrastructure_encryption_enabled     = var.is_kms_enabled
  public_network_access_enabled         = !var.is_frontend_private_link_enabled
  network_security_group_rules_required = "NoAzureDatabricksRules"
  default_storage_firewall_enabled      = var.boolean_create_private_dbfs
  access_connector_id                   = var.boolean_create_private_dbfs ? azurerm_databricks_access_connector.ws[0].id : null

  enhanced_security_compliance {
    automatic_cluster_update_enabled      = var.enhanced_security_compliance.automatic_cluster_update_enabled
    compliance_security_profile_enabled   = var.enhanced_security_compliance.compliance_security_profile_enabled
    compliance_security_profile_standards = var.enhanced_security_compliance.compliance_security_profile_standards
    enhanced_security_monitoring_enabled  = var.enhanced_security_compliance.enhanced_security_monitoring_enabled
  }

  custom_parameters {
    storage_account_name                                 = local.dbfs_name
    no_public_ip                                         = true
    virtual_network_id                                   = var.network_configuration.virtual_network_id
    public_subnet_name                                   = local.public_subnet.resource_name
    private_subnet_name                                  = local.private_subnet.resource_name
    public_subnet_network_security_group_association_id  = var.network_configuration.public_subnet_network_security_group_association_id
    private_subnet_network_security_group_association_id = var.network_configuration.private_subnet_network_security_group_association_id
  }

  tags = var.tags
}

# Wait for 10 seconds after workspace creation to allow for APIs to become available
resource "time_sleep" "workspace_wait" {
  triggers = {
    workspace_id = azurerm_databricks_workspace.this.workspace_id
  }
  create_duration  = "10s"
  destroy_duration = "10s"
}

# Grant admin access to the provisioner account to the workspace, used for downstream workspace provider
resource "azurerm_role_assignment" "contributor" {
  role_definition_name = "contributor"
  scope                = azurerm_databricks_workspace.this.id
  principal_id         = var.provisioner_principal_id
  description          = "This is granted by the Databricks SRA Terraform module. It grants workspace admin to the provisioner principal of the workspace."
}

# This resource is used to output the workspace URL of the workspace AFTER the provisioner account has been granted admin
# This removes the need to use depends_on in downstream modules that use this workspace in their aliased provider.
resource "null_resource" "admin_wait" {
  triggers = {
    workspace_url = azurerm_databricks_workspace.this.workspace_url
    workspace_id  = azurerm_role_assignment.contributor.scope
    metastore_id  = databricks_metastore_assignment.this.metastore_id
  }
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
  count = var.is_kms_enabled ? 1 : 0

  workspace_id     = azurerm_databricks_workspace.this.id
  key_vault_key_id = var.managed_disk_key_id

  depends_on = [azurerm_key_vault_access_policy.dbstorage]
}

resource "azurerm_key_vault_access_policy" "dbstorage" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.this.storage_account_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.this.storage_account_identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_key_vault_access_policy" "dbmanageddisk" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.this.managed_disk_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.this.managed_disk_identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

# Define a Databricks metastore assignment
resource "databricks_metastore_assignment" "this" {
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = var.metastore_id
}

resource "databricks_mws_ncc_binding" "this" {
  network_connectivity_config_id = var.ncc_id
  workspace_id                   = azurerm_databricks_workspace.this.workspace_id
}

resource "databricks_workspace_network_option" "this" {
  network_policy_id = var.network_policy_id
  workspace_id      = azurerm_databricks_workspace.this.workspace_id
}
