locals {
  firewall_application_rules = [
    for rule in [
      {
        name              = "IPinfo"
        source_ip_groups  = [azurerm_ip_group.this.id]
        destination_fqdns = ["*.ipinfo.io", "ipinfo.io"]
        protocols = toset([
          {
            port = "443",
            type = "Https"
          },
          {
            port = "8080",
            type = "Http"
          },
          {
            port = "80",
            type = "Http"
          }
        ])
      },
      {
        name              = "ganglia"
        source_ip_groups  = [azurerm_ip_group.this.id]
        destination_fqdns = ["cdnjs.cloudflare.com"]
        protocols = toset([
          {
            port = "443",
            type = "Https"
          }
        ])
      },
      length(var.public_repos) > 0 ? {
        name              = "public-repos"
        source_ip_groups  = [azurerm_ip_group.this.id]
        destination_fqdns = var.public_repos
        protocols = toset([
          {
            port = "443",
            type = "Https"
          }
        ])
      } : null
    ] : rule if rule != null
  ]
}

# Define a public IP resource for the Azure Firewall
resource "azurerm_public_ip" "this" {
  count = var.is_firewall_enabled ? 1 : 0

  name                = module.naming.public_ip.name_unique
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.firewall_sku
  tags                = var.tags
}

# Define a firewall policy resource
resource "azurerm_firewall_policy" "this" {
  count = var.is_firewall_enabled ? 1 : 0

  name                = module.naming.firewall_policy.name_unique
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Define a firewall policy rule collection group resource
resource "azurerm_firewall_policy_rule_collection_group" "this" {
  count = var.is_firewall_enabled ? 1 : 0

  name               = "${var.resource_suffix}-databricks"
  firewall_policy_id = azurerm_firewall_policy.this[0].id
  priority           = 200

  # Define network rule collection within the rule collection group
  network_rule_collection {
    name     = "${var.resource_suffix}-databricks-network-rc"
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
    name     = "${var.resource_suffix}-databricks-app-rc"
    priority = 101
    action   = "Allow"

    # Define rules within the application rule collection
    dynamic "rule" {
      for_each = local.firewall_application_rules
      content {
        name              = rule.value.name
        source_ip_groups  = rule.value.source_ip_groups
        destination_fqdns = rule.value.destination_fqdns
        dynamic "protocols" {
          for_each = rule.value.protocols
          content {
            port = protocols.value.port
            type = protocols.value.type
          }
        }
      }
    }
  }
}

# Define a firewall resource
resource "azurerm_firewall" "this" {
  count = var.is_firewall_enabled ? 1 : 0

  name                = module.naming.firewall.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku
  firewall_policy_id  = azurerm_firewall_policy.this[0].id


  # Define IP configuration for the firewall
  ip_configuration {
    name                 = "firewall-public-ip-config"
    subnet_id            = module.hub_network.subnet_ids["AzureFirewallSubnet"]
    public_ip_address_id = azurerm_public_ip.this[0].id
  }

  tags = var.tags

  depends_on = [
    azurerm_firewall_policy_rule_collection_group.this
  ]
}

resource "azurerm_ip_group" "this" {
  name                = "${var.resource_suffix}-adb-subnets"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  lifecycle {
    ignore_changes = [cidrs]
  }
}

# Create an Azure route table resource
resource "azurerm_route_table" "this" {
  name                = module.naming.route_table.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Create a route in the route table to direct traffic to the firewall
resource "azurerm_route" "firewall_route" {
  count = var.is_firewall_enabled ? 1 : 0

  name                   = "to-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.this[0].ip_configuration[0].private_ip_address
}
