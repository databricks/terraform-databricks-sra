<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
resource "azurerm_key_vault" "this" {
  count = var.is_kms_enabled ? 1 : 0

  name                     = module.naming.key_vault.name_unique
<<<<<<< HEAD
=======
# Why do `key_opts` and `key_permissions` differ in terms of required capitalization?
# Define the Azure Key Vault resource
=======
>>>>>>> 6df143a (deployed without UC)
resource "azurerm_key_vault" "this" {
  count = var.is_kms_enabled ? 1 : 0

<<<<<<< HEAD
  name                     = "${local.prefix}-kv"
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
=======
  name                     = module.naming.key_vault
>>>>>>> 900395d (naming)
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
<<<<<<< HEAD
  tenant_id                = var.client_config.tenant_id
  purge_protection_enabled = true
<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
=======
  # enable_rbac_authorization = true
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf

  sku_name                   = "premium"
  soft_delete_retention_days = 7

  tags = var.tags
<<<<<<< HEAD
=======
  tenant_id                = data.azurerm_client_config.current.tenant_id
=======
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  tenant_id                = var.client_config.tenant_id
>>>>>>> 8d44021 (serverless and classic compute working)
  purge_protection_enabled = true

  sku_name                   = "premium"
  soft_delete_retention_days = 7
<<<<<<< HEAD
>>>>>>> 6df143a (deployed without UC)
=======

  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 8d44021 (serverless and classic compute working)
=======
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)
}

# Define a key in the Azure Key Vault for managed services
resource "azurerm_key_vault_key" "managed_services" {
  count = var.is_kms_enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
  name         = "${module.naming.key_vault_key.name}-adb-services"
=======
  name         = "${local.prefix}-adb-services"
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
=======
  name         = "${module.naming.key_vault_key}-adb-services"
>>>>>>> 900395d (naming)
=======
  name         = "${module.naming.key_vault_key.name}-adb-services"
>>>>>>> 8d44021 (serverless and classic compute working)
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

<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
  tags = var.tags

=======
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Define a key in the Azure Key Vault for managed disks
resource "azurerm_key_vault_key" "managed_disk" {
  count = var.is_kms_enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
  name         = "${module.naming.key_vault_key.name}-adb-disk"
=======
  name         = "${local.prefix}-adb-disk"
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
=======
  name         = "${module.naming.key_vault_key}-adb-disk"
>>>>>>> 900395d (naming)
=======
  name         = "${module.naming.key_vault_key.name}-adb-disk"
>>>>>>> 8d44021 (serverless and classic compute working)
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

<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
  tags = var.tags

=======
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Define an access policy for the Azure Key Vault
resource "azurerm_key_vault_access_policy" "terraform" {
  count = var.is_kms_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  tenant_id    = azurerm_key_vault.this[0].tenant_id
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
  object_id    = var.client_config.object_id
=======
  object_id    = data.azurerm_client_config.current.object_id
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
=======
  object_id    = var.client_config.object_id
>>>>>>> 8d44021 (serverless and classic compute working)

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
  resource_group_name = azurerm_resource_group.this.name

<<<<<<< HEAD
<<<<<<< HEAD
  tags = var.tags
=======
  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 8d44021 (serverless and classic compute working)
=======
  tags = var.tags
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)
}

resource "azurerm_private_endpoint" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
  name                = "${module.naming.private_endpoint.name}-kv"
=======
  name                = "${local.prefix}-kv-pe"
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
=======
  name                = "${module.naming.private_endpoint}-kv"
>>>>>>> 900395d (naming)
=======
  name                = "${module.naming.private_endpoint.name}-kv"
>>>>>>> 8d44021 (serverless and classic compute working)
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

<<<<<<< HEAD
<<<<<<< HEAD
  tags = var.tags
=======
  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 8d44021 (serverless and classic compute working)
=======
  tags = var.tags
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/keyvault.tf
  name                  = "${var.resource_suffix}-keyvault-vnetlink"
=======
  name                  = "${local.prefix}-keyvault-vnetlink"
>>>>>>> d243d1c (make key vault optional on Azure):azure/tf/modules/azure_hub/keyvault.tf
=======
  name                  = "${var.resource_suffix}-keyvault-vnetlink"
>>>>>>> 900395d (naming)
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = azurerm_virtual_network.this.id

<<<<<<< HEAD
<<<<<<< HEAD
  tags = var.tags
=======
  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 8d44021 (serverless and classic compute working)
=======
  tags = var.tags
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)
}
