resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.firewall_subnet_address_prefixes]
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.AzureActiveDirectory"
  ]
}

resource "azurerm_public_ip" "this" {
  name                = "firewall-public-ip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "this" {
  name                = "databricks-fwpolicy"
  resource_group_name = var.hub_resource_group_name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "databricks-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 200
  application_rule_collection {
    name     = "databricks-app-rc"
    priority = 200
    action   = "Allow"

    rule {
      name              = "public-repos"
      source_addresses  = ["*"]
      destination_fqdns = var.public_repos
      protocols {
        port = "443"
        type = "Https"
      }
      protocols {
        port = "80"
        type = "Http"
      }
    }

    rule {
      name              = "IPinfo"
      source_addresses  = ["*"]
      destination_fqdns = ["*.ipinfo.io", "ipinfo.io"]
      protocols {
        port = "443"
        type = "Https"
      }
      protocols {
        port = "8080"
        type = "Http"
      }
      protocols {
        port = "80"
        type = "Http"
      }
    }
  }

  depends_on = [
    resource.azurerm_firewall_policy.this
  ]

}

resource "azurerm_firewall" "this" {
  name                = "${azurerm_virtual_network.this.name}-firewall"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.this.id

  ip_configuration {
    name                 = "firewall-public-ip-config"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.this.id
  }

  depends_on = [
    resource.azurerm_firewall_policy_rule_collection_group.this
  ]

}
