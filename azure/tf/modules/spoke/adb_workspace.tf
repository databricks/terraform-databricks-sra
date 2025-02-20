# Define an Azure Databricks workspace resource
resource "azurerm_databricks_workspace" "this" {
<<<<<<< HEAD
<<<<<<< HEAD
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

  custom_parameters {
    storage_account_name                                 = local.dbfs_name
    no_public_ip                                         = true
=======
  name                = "${var.prefix}-adb-workspace"
=======
  # name                = "${var.resource_suffix}-adb-workspace"
<<<<<<< HEAD
  name                = module.naming.databricks_workspace
>>>>>>> 900395d (naming)
=======
  name                = module.naming.databricks_workspace.name
>>>>>>> 6df143a (deployed without UC)
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
>>>>>>> 60cc2bc (remove redundant module naming)
    virtual_network_id                                   = azurerm_virtual_network.this.id
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
  }

  tags = var.tags
<<<<<<< HEAD
=======

  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 60cc2bc (remove redundant module naming)
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
  count = var.is_kms_enabled ? 1 : 0

  workspace_id     = azurerm_databricks_workspace.this.id
  key_vault_key_id = var.managed_disk_key_id

<<<<<<< HEAD
  depends_on = [azurerm_key_vault_access_policy.dbstorage]
}

# Define an Azure Key Vault access policy for Databricks
resource "azurerm_key_vault_access_policy" "dbstorage" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.this.storage_account_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.this.storage_account_identity[0].principal_id
=======
  depends_on = [azurerm_key_vault_access_policy.databricks]
}

# Define an Azure Key Vault access policy for Databricks
resource "azurerm_key_vault_access_policy" "databricks" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = var.key_vault_id
<<<<<<< HEAD
  tenant_id    = azurerm_databricks_workspace.this.storage_account_identity.0.tenant_id
  object_id    = azurerm_databricks_workspace.this.storage_account_identity.0.principal_id
>>>>>>> 60cc2bc (remove redundant module naming)

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

<<<<<<< HEAD
resource "azurerm_key_vault_access_policy" "dbmanageddisk" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.this.managed_disk_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.this.managed_disk_identity[0].principal_id
=======
# Define an Azure Key Vault access policy for managed disks
resource "azurerm_key_vault_access_policy" "managed" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.databricks_app_object_id
>>>>>>> 60cc2bc (remove redundant module naming)
=======
  tenant_id    = azurerm_databricks_workspace.this.storage_account_identity[0].tenant_id
  object_id    = azurerm_databricks_workspace.this.storage_account_identity[0].principal_id
>>>>>>> 6df143a (deployed without UC)

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

# Define a Databricks metastore assignment
resource "databricks_metastore_assignment" "this" {
<<<<<<< HEAD
<<<<<<< HEAD
  count        = var.is_kms_enabled ? 1 : 0
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = var.metastore_id
}

resource "databricks_mws_ncc_binding" "this" {
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  workspace_id                   = azurerm_databricks_workspace.this.workspace_id
}
=======
=======
  count = var.is_kms_enabled ? 1 : 0
>>>>>>> 6df143a (deployed without UC)
  # may need to use an explicit workspace-authenticated provider here
  # provider = databricks.workspace
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = var.metastore_id
}
>>>>>>> 60cc2bc (remove redundant module naming)
