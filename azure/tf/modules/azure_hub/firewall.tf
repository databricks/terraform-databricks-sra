resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [cidrsubnet(var.hub_cidr, 3, 0)]
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

resource "azurerm_ip_group" "this" {
  name                = "databricks-subnets"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "databricks"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 200
  network_rule_collection {
    name     = databricks-network-rc
    priority = 100
    action   = "Allow"

    rule {
      name                  = "adb-storage"
      protocols             = ["TCP, UDP"]
      source_ip_groups      = azurerm_ip_group.this
      destination_addresses = [lookup(local.service_tags, "storage", "Storage")]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "adb-sql"
      protocols             = ["TCP"]
      source_ip_groups      = azurerm_ip_group.this
      destination_addresses = [lookup(local.service_tags, "sql", "Sql")]
      destination_ports     = ["3306"]
    }

    rule {
      name                  = "adb-eventhub"
      protocols             = ["TCP"]
      source_ip_groups      = azurerm_ip_group.this
      destination_addresses = [lookup(local.service_tags, "eventhub", "EventHub")]
      destination_ports     = ["9093"]
    }
  }

  application_rule_collection {
    name     = "databricks-app-rc"
    priority = 101
    action   = "Allow"

    rule {
      name              = "public-repos"
      source_ip_groups  = azurerm_ip_group.this
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
      source_ip_groups  = azurerm_ip_group.this
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

      rule {
        name              = "ganglia"
        source_ip_groups  = azurerm_ip_group.this
        destination_fqdns = ["cdnjs.cloudflare.com"]
        protocols {
          port = "443"
          type = "Https"
        }
      }
    }
  }
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
