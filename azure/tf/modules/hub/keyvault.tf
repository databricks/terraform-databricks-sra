# Why do `key_opts` and `key_permissions` differ in terms of required capitalization?
# Define the Azure Key Vault resource
resource "azurerm_key_vault" "this" {
  count = var.is_kms_enabled ? 1 : 0

  name                     = "${local.prefix}-kv"
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  tenant_id                = local.tenant_id
  purge_protection_enabled = true
  # enable_rbac_authorization = true

  sku_name                   = "premium"
  soft_delete_retention_days = 7

  lifecycle {
    ignore_changes = [tags]
  }
}

# Define a key in the Azure Key Vault for managed services
resource "azurerm_key_vault_key" "managed_services" {
  count = var.is_kms_enabled ? 1 : 0

  name         = "${local.prefix}-adb-services"
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

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Define a key in the Azure Key Vault for managed disks
resource "azurerm_key_vault_key" "managed_disk" {
  count = var.is_kms_enabled ? 1 : 0

  name         = "${local.prefix}-adb-disk"
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

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Define an access policy for the Azure Key Vault
resource "azurerm_key_vault_access_policy" "terraform" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  tenant_id    = azurerm_key_vault.this[0].tenant_id
  object_id    = data.azurerm_client_config.current.object_id

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

resource "azurerm_private_dns_zone" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_endpoint" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

  name                = "${local.prefix}-kv-pe"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

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

}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

  name                  = "${local.prefix}-keyvault-vnetlink"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = azurerm_virtual_network.this.id
}
