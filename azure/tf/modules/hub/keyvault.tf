resource "azurerm_key_vault" "this" {
  count = var.is_kms_enabled ? 1 : 0

  name                     = module.naming.key_vault.name_unique
  location                 = var.location
  resource_group_name      = var.resource_group_name
  tenant_id                = var.client_config.tenant_id
  purge_protection_enabled = true

  sku_name                   = "premium"
  soft_delete_retention_days = 7

  tags = var.tags
}

# Define a key in the Azure Key Vault for managed services
resource "azurerm_key_vault_key" "managed_services" {
  count = var.is_kms_enabled ? 1 : 0

  name         = "${module.naming.key_vault_key.name}-adb-services"
  key_vault_id = azurerm_key_vault.this[0].id
  key_type     = "RSA"
  key_size     = 2048

  # Define the key options for the managed services key
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = var.tags

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Define a key in the Azure Key Vault for managed disks
resource "azurerm_key_vault_key" "managed_disk" {
  count = var.is_kms_enabled ? 1 : 0

  name         = "${module.naming.key_vault_key.name}-adb-disk"
  key_vault_id = azurerm_key_vault.this[0].id
  key_type     = "RSA"
  key_size     = 2048

  # Define the key options for the managed disk key
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = var.tags

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Define an access policy for the Azure Key Vault
resource "azurerm_key_vault_access_policy" "terraform" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  tenant_id    = azurerm_key_vault.this[0].tenant_id
  object_id    = var.client_config.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
    "Delete",
    "Restore",
    "Recover",
    "Update",
    "Purge",
    "GetRotationPolicy"
  ]
}

#TODO: Document this
resource "azurerm_key_vault_access_policy" "databricks" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  tenant_id    = var.client_config.tenant_id
  object_id    = var.databricks_app_reg.object_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_private_dns_zone" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_endpoint" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

  name                = "${module.naming.private_endpoint.name}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.hub_network.subnet_ids["privatelink"]

  private_service_connection {
    name                           = "keyvault"
    private_connection_resource_id = azurerm_key_vault.this[0].id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "keyvault"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault[0].id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

  name                  = "${var.resource_suffix}-keyvault-vnetlink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = module.hub_network.vnet_id

  tags = var.tags
}
