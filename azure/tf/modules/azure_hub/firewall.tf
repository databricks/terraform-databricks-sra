# Define a subnet resource for the Azure Firewall
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.subnets["firewall"]]
}

# Define a public IP resource for the Azure Firewall
resource "azurerm_public_ip" "this" {
  name                = "firewall-public-ip"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Define a firewall policy resource
resource "azurerm_firewall_policy" "this" {
  name                = "databricks-fwpolicy"
  resource_group_name = var.hub_resource_group_name
  location            = azurerm_resource_group.hub.location
}

# Define an IP group resource
resource "azurerm_ip_group" "this" {
  name                = "databricks-subnets"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
}

# Define a firewall policy rule collection group resource
resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "databricks"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 200

  # Define network rule collection within the rule collection group
  network_rule_collection {
    name     = "databricks-network-rc"
    priority = 100
    action   = "Allow"

    # Define rules within the network rule collection
    rule {
      name                  = "adb-storage"
      protocols             = ["TCP", "UDP"]
      source_ip_groups      = [azurerm_ip_group.this.id]
      destination_addresses = [lookup(local.service_tags, "storage", "Storage")]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "adb-sql"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.this.id]
      destination_addresses = [lookup(local.service_tags, "sql", "Sql")]
      destination_ports     = ["3306"]
    }

    rule {
      name                  = "adb-eventhub"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.this.id]
      destination_addresses = [lookup(local.service_tags, "eventhub", "EventHub")]
      destination_ports     = ["9093"]
    }
  }

  # Define application rule collection within the rule collection group
  application_rule_collection {
    name     = "databricks-app-rc"
    priority = 101
    action   = "Allow"

    # Define rules within the application rule collection
    rule {
      name              = "public-repos"
      source_ip_groups  = [azurerm_ip_group.this.id]
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
      source_ip_groups  = [azurerm_ip_group.this.id]
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

    rule {
      name              = "ganglia"
      source_ip_groups  = [azurerm_ip_group.this.id]
      destination_fqdns = ["cdnjs.cloudflare.com"]
      protocols {
        port = "443"
        type = "Https"
      }
    }
  }
}

# Define a firewall resource
resource "azurerm_firewall" "this" {
  name                = "${azurerm_virtual_network.this.name}-firewall"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.this.id

  # Define IP configuration for the firewall
  ip_configuration {
    name                 = "firewall-public-ip-config"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.this.id
  }

  depends_on = [
    resource.azurerm_firewall_policy_rule_collection_group.this
  ]
}
