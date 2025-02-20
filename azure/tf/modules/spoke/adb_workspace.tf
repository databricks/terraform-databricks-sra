# Define an Azure Databricks workspace resource
resource "azurerm_databricks_workspace" "this" {
  # name                = "${var.resource_suffix}-adb-workspace"
  name                = module.naming.databricks_workspace.name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = "premium"

  managed_disk_cmk_key_vault_key_id                   = var.is_kms_enabled ? var.managed_disk_key_id : null
  managed_services_cmk_key_vault_key_id               = var.is_kms_enabled ? var.managed_services_key_id : null
  managed_disk_cmk_rotation_to_latest_version_enabled = var.is_kms_enabled ? true : null
  customer_managed_key_enabled                        = var.is_kms_enabled
  infrastructure_encryption_enabled                   = var.is_kms_enabled
  public_network_access_enabled                       = !var.is_frontend_private_link_enabled
  network_security_group_rules_required               = var.is_frontend_private_link_enabled ? "NoAzureDatabricksRules" : "AllRules"

  custom_parameters {
    no_public_ip                                         = var.is_frontend_private_link_enabled
    virtual_network_id                                   = azurerm_virtual_network.this.id
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
  count = var.is_kms_enabled ? 1 : 0

  workspace_id     = azurerm_databricks_workspace.this.id
  key_vault_key_id = var.managed_disk_key_id

  depends_on = [azurerm_key_vault_access_policy.databricks]
}

# Define an Azure Key Vault access policy for Databricks
resource "azurerm_key_vault_access_policy" "databricks" {
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

# Define a Databricks metastore assignment
resource "databricks_metastore_assignment" "this" {
  count = var.is_kms_enabled ? 1 : 0
  # may need to use an explicit workspace-authenticated provider here
  # provider = databricks.workspace
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = var.metastore_id
}
