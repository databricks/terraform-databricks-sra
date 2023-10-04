# # Why do `key_opts` and `key_permissions` differ in terms of required capitalization?
# # Define the Azure Key Vault resource
# resource "azurerm_key_vault" "this" {
#   name                = "example-hub-keyvault"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   tenant_id           = local.tenant_id

#   sku_name = "premium"

#   soft_delete_retention_days = 7
# }

# # Define a key in the Azure Key Vault for managed services
# resource "azurerm_key_vault_key" "managed_services" {
#   depends_on = [azurerm_key_vault_access_policy.terraform]

#   name         = "adb-services"
#   key_vault_id = azurerm_key_vault.this.id
#   key_type     = "RSA"
#   key_size     = 2048

#   # Define the key options for the managed services key
#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]
# }

# # Define a key in the Azure Key Vault for managed disks
# resource "azurerm_key_vault_key" "managed_disk" {
#   depends_on = [azurerm_key_vault_access_policy.terraform]

#   name         = "adb-disk"
#   key_vault_id = azurerm_key_vault.this.id
#   key_type     = "RSA"
#   key_size     = 2048

#   # Define the key options for the managed disk key
#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]
# }

# # Define an access policy for the Azure Key Vault
# resource "azurerm_key_vault_access_policy" "terraform" {
#   key_vault_id = azurerm_key_vault.this.id
#   tenant_id    = azurerm_key_vault.this.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id

#   # Define the key permissions for the access policy
#   key_permissions = [
#     "Get",
#     "List",
#     "Create",
#     "Decrypt",
#     "Encrypt",
#     "Sign",
#     "UnwrapKey",
#     "Verify",
#     "WrapKey",
#     "Delete",
#     "Restore",
#     "Recover",
#     "Update",
#     "Purge",
#     "GetRotationPolicy",
#   ]
# }
