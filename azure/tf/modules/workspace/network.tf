data "azurerm_virtual_network" "this" {
  name                = var.network_configuration.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "private" {
  name                 = var.network_configuration.private_subnet_name
  resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
}

data "azurerm_subnet" "public" {
  name                 = var.network_configuration.public_subnet_name
  resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
}

data "azurerm_subnet" "private_endpoint" {
  name                 = var.network_configuration.private_endpoint_subnet_name
  resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
}
