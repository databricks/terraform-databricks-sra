# Define an Azure Databricks workspace resource
resource "azurerm_databricks_workspace" "this" {
  name                        = module.naming.databricks_workspace.name
  resource_group_name         = azurerm_resource_group.this.name
  managed_resource_group_name = local.managed_rg_name
  location                    = var.location
  sku                         = "premium"

  # managed_disk_cmk_rotation_to_latest_version_enabled = var.is_kms_enabled ? true : false
  managed_disk_cmk_key_vault_key_id     = var.is_kms_enabled ? var.managed_disk_key_id : null
  managed_services_cmk_key_vault_key_id = var.is_kms_enabled ? var.managed_services_key_id : null
  customer_managed_key_enabled          = var.is_kms_enabled
  infrastructure_encryption_enabled     = var.is_kms_enabled
  public_network_access_enabled         = !var.is_frontend_private_link_enabled
  network_security_group_rules_required = var.is_frontend_private_link_enabled ? "NoAzureDatabricksRules" : "AllRules"
  default_storage_firewall_enabled      = var.boolean_create_private_dbfs
  access_connector_id                   = var.boolean_create_private_dbfs ? azurerm_databricks_access_connector.ws[0].id : null

  custom_parameters {
    storage_account_name                                 = local.dbfs_name
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
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
resource "databricks_mws_permission_assignment" "admin" {
  workspace_id = time_sleep.workspace_wait.triggers.workspace_id
  principal_id = var.provisioner_principal_id
  permissions  = ["ADMIN"]
}

# This resource is used to output the workspace URL of the workspace AFTER the provisioner account has been granted admin
# This removes the need to use depends_on in downstream modules that use this workspace in their aliased provider.
resource "null_resource" "admin_wait" {
  triggers = {
    workspace_url = azurerm_databricks_workspace.this.workspace_url
    workspace_id  = databricks_mws_permission_assignment.admin.workspace_id
  }
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
  count = var.is_kms_enabled ? 1 : 0

  workspace_id     = azurerm_databricks_workspace.this.id
  key_vault_key_id = var.managed_disk_key_id

  depends_on = [azurerm_key_vault_access_policy.dbstorage]
}

# Define an Azure Key Vault access policy for Databricks
resource "azurerm_key_vault_access_policy" "dbstorage" {
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
  count        = var.is_kms_enabled ? 1 : 0
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
