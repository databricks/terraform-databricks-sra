# Key access is granted with Azure RBAC role assignments (see below). The vault does not use access policies.
resource "azurerm_key_vault" "this" {
  count = var.is_kms_enabled ? 1 : 0

  # name_unique is truncated to 24 characters, which can leave a trailing dash (invalid) for long suffixes.
  name                       = replace(module.naming.key_vault.name_unique, "/-+$/", "")
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.client_config.tenant_id
  purge_protection_enabled   = true
  rbac_authorization_enabled = true

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

  depends_on = [time_sleep.key_vault_rbac]
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

  depends_on = [time_sleep.key_vault_rbac]
}

# The identity running Terraform creates and manages the customer-managed keys.
resource "azurerm_role_assignment" "key_vault_terraform" {
  count = var.is_kms_enabled ? 1 : 0

  scope                = azurerm_key_vault.this[0].id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = var.client_config.object_id
  description          = "Granted by the Databricks SRA Terraform module to create and manage the customer-managed keys."
}

# The AzureDatabricks first-party application wraps and unwraps the managed services key.
resource "azurerm_role_assignment" "key_vault_databricks" {
  count = var.is_kms_enabled ? 1 : 0

  scope                = azurerm_key_vault.this[0].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = var.databricks_app_reg.object_id
  principal_type       = "ServicePrincipal"
  description          = "Granted by the Databricks SRA Terraform module for customer-managed keys for managed services."
}

# Role assignments take time to reach the Key Vault data plane. The keys wait on this, and so do the workspaces that use
# the managed services key, since they reference the key outputs. The triggers re-run the wait if either assignment is
# replaced, for example when a different identity runs Terraform.
resource "time_sleep" "key_vault_rbac" {
  count = var.is_kms_enabled ? 1 : 0

  create_duration = "60s"

  triggers = {
    terraform  = azurerm_role_assignment.key_vault_terraform[0].id
    databricks = azurerm_role_assignment.key_vault_databricks[0].id
  }
}

resource "azurerm_private_dns_zone" "key_vault" {
  count = var.is_kms_enabled ? 1 : 0

  name                = var.private_dns_zone_names.key_vault
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

  name                = "${var.resource_suffix}-keyvault-vnetlink"
  private_dns_zone_id = azurerm_private_dns_zone.key_vault[0].id
  virtual_network_id  = module.hub_network.vnet_id

  tags = var.tags
}
