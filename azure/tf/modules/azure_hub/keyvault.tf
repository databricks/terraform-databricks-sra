# Why do `key_opts` and `key_permissions` differ in terms of required capitalization?
# Define the Azure Key Vault resource
resource "azurerm_key_vault" "example" {
  name                     = "example-hub-keyvault"
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  tenant_id                = local.tenant_id
  purge_protection_enabled = true
  # enable_rbac_authorization = true

  sku_name = "premium"

  soft_delete_retention_days = 7

  lifecycle {
    ignore_changes = [tags]
  }
}

# Define a key in the Azure Key Vault for managed services
resource "azurerm_key_vault_key" "managed_services" {
  depends_on = [azurerm_key_vault_access_policy.terraform]

  name         = "adb-services"
  key_vault_id = azurerm_key_vault.example.id
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
}

# Define a key in the Azure Key Vault for managed disks
resource "azurerm_key_vault_key" "managed_disk" {
  depends_on = [azurerm_key_vault_access_policy.terraform]

  name         = "adb-disk"
  key_vault_id = azurerm_key_vault.example.id
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
}

# resource "azurerm_role_assignment" "key_vault_reader" {
#   scope              = azurerm_key_vault.example.id
#   role_definition_id = "21090545-7ca7-4776-b22c-e363652d74d2"
#   principal_id       = data.azurerm_client_config.current.object_id
# }

# Define an access policy for the Azure Key Vault
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = azurerm_key_vault.example.tenant_id
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
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "${local.prefix}-kv-pe"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  private_service_connection {
    name                           = "keyvault"
    private_connection_resource_id = azurerm_key_vault.example.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "keyvault"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }

}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "${local.prefix}-keyvault-vnetlink"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.this.id
}
