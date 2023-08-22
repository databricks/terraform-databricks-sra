resource "azurerm_databricks_workspace" "this" {
  name                = var.workspace_name
  resource_group_name = var.databricks_resource_group_name
  location            = var.location
  sku                 = "premium"
  # need to get the below AKV ids from hub outputs
  # managed_disk_cmk_key_vault_key_id = 
  # managed_services_cmk_key_vault_key_id = 
  # managed_disk_cmk_rotation_to_latest_version_enabled = true
  customer_managed_key_enabled          = true
  infrastructure_encryption_enabled     = true
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
  }

  tags = var.tags
}

resource "databricks_metastore_assignment" "this" {
  provider = databricks.workspace
  # may need to use an explicit workspace-authenticated provider here
  workspace_id = azurerm_databricks_workspace.this.id
  metastore_id = var.metastore_id
}
