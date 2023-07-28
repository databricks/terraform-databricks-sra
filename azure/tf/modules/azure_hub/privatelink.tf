resource "azurerm_subnet" "privatelink" {
  name                 = "privatelink-subnet-${var.project_name}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes                          = var.privatelink_subnet_address_prefixes
  private_endpoint_network_policies_enabled = true
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

