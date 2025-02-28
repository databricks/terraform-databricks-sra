# Define a subnet resource for the Azure Firewall
resource "azurerm_subnet" "firewall" {
  count = var.is_firewall_enabled ? 1 : 0

  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.subnet_map["firewall"]]
}

# Define a public IP resource for the Azure Firewall
resource "azurerm_public_ip" "this" {
  count = var.is_firewall_enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
  name                = module.naming.public_ip.name_unique
=======
  name                = "${local.prefix}-fw-public-ip"
>>>>>>> 8af490c (make firewall optional):azure/tf/modules/azure_hub/firewall.tf
=======
  #name                = "${local.resource_suffix}-fw-public-ip"
  name                = module.naming.public_ip
>>>>>>> 900395d (naming)
=======
  name                = module.naming.public_ip.name_unique
>>>>>>> 8d44021 (serverless and classic compute working)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = var.firewall_sku
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
  tags                = var.tags
=======

  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 8af490c (make firewall optional):azure/tf/modules/azure_hub/firewall.tf
=======
  tags                = var.tags
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)
}

# Define a firewall policy resource
resource "azurerm_firewall_policy" "this" {
  count = var.is_firewall_enabled ? 1 : 0
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf

  name                = module.naming.firewall_policy.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

=======

  name                = module.naming.firewall_policy.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

>>>>>>> 8af490c (make firewall optional):azure/tf/modules/azure_hub/firewall.tf
# Define a firewall policy rule collection group resource
resource "azurerm_firewall_policy_rule_collection_group" "this" {
  count = var.is_firewall_enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
  name               = "${var.resource_suffix}-databricks"
=======
  name               = "${local.prefix}-databricks"
>>>>>>> 8af490c (make firewall optional):azure/tf/modules/azure_hub/firewall.tf
=======
  name               = "${var.resource_suffix}-databricks"
>>>>>>> 900395d (naming)
  firewall_policy_id = azurerm_firewall_policy.this[0].id
  priority           = 200

  # Define network rule collection within the rule collection group
  network_rule_collection {
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
    name     = "${var.resource_suffix}-databricks-network-rc"
=======
    name     = "${local.prefix}-databricks-network-rc"
>>>>>>> 8af490c (make firewall optional):azure/tf/modules/azure_hub/firewall.tf
=======
    name     = "${var.resource_suffix}-databricks-network-rc"
>>>>>>> 900395d (naming)
    priority = 100
    action   = "Allow"

    # Define rules within the network rule collection
    rule {
      name                  = "adb-services"
      protocols             = ["TCP", "UDP"]
      source_ip_groups      = [azurerm_ip_group.this.id]
      destination_addresses = ["AzureDatabricks"]
      destination_ports     = ["443"]
    }
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
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
    name     = "${var.resource_suffix}-databricks-app-rc"
=======
    name     = "${local.prefix}-databricks-app-rc"
>>>>>>> 8af490c (make firewall optional):azure/tf/modules/azure_hub/firewall.tf
=======
    name     = "${var.resource_suffix}-databricks-app-rc"
>>>>>>> 900395d (naming)
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
  count = var.is_firewall_enabled ? 1 : 0

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
  name                = module.naming.firewall.name
=======
  name                = "${azurerm_virtual_network.this.name}-firewall"
>>>>>>> 8af490c (make firewall optional):azure/tf/modules/azure_hub/firewall.tf
=======
  name                = module.naming.firewall
>>>>>>> 900395d (naming)
=======
  name                = module.naming.firewall.name
>>>>>>> 8d44021 (serverless and classic compute working)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku
  firewall_policy_id  = azurerm_firewall_policy.this[0].id


  # Define IP configuration for the firewall
  ip_configuration {
    name                 = "firewall-public-ip-config"
    subnet_id            = azurerm_subnet.firewall[0].id
    public_ip_address_id = azurerm_public_ip.this[0].id
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

  depends_on = [
    azurerm_firewall_policy_rule_collection_group.this
  ]
}

resource "azurerm_ip_group" "this" {
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
  name                = "${var.resource_suffix}-adb-subnets"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
<<<<<<< HEAD
=======
  name                = "${local.prefix}-databricks-subnets"
=======
  name                = "${var.resource_suffix}-adb-subnets"
>>>>>>> 900395d (naming)
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
>>>>>>> 7569a22 (moved route table changes back to firewall.tf):azure/tf/modules/azure_hub/firewall.tf
=======
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)

  lifecycle {
    ignore_changes = [cidrs]
  }
}

# Create an Azure route table resource
resource "azurerm_route_table" "this" {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
=======
>>>>>>> 6df143a (deployed without UC)
  name                = module.naming.route_table.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

<<<<<<< HEAD
<<<<<<< HEAD
  tags = var.tags
=======
  name                = "${local.prefix}-route-table"
=======
  name                = module.naming.route_table
>>>>>>> 900395d (naming)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
>>>>>>> 7569a22 (moved route table changes back to firewall.tf):azure/tf/modules/azure_hub/firewall.tf
=======
  lifecycle {
    ignore_changes = [tags]
  }
>>>>>>> 8d44021 (serverless and classic compute working)
=======
  tags = var.tags
>>>>>>> 3603a0f (fix: Remove ignore_changes on all tags and pass var.tags as tags argument)
}

# Create a route in the route table to direct traffic to the firewall
resource "azurerm_route" "firewall_route" {
  count = var.is_firewall_enabled ? 1 : 0

  name                   = "to-firewall"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/hub/firewall.tf
  next_hop_in_ip_address = azurerm_firewall.this[0].ip_configuration[0].private_ip_address
=======
  next_hop_in_ip_address = azurerm_firewall.this[0].ip_configuration.0.private_ip_address
>>>>>>> 7569a22 (moved route table changes back to firewall.tf):azure/tf/modules/azure_hub/firewall.tf
=======
  next_hop_in_ip_address = azurerm_firewall.this[0].ip_configuration[0].private_ip_address
>>>>>>> 1f7336f (style: Access list index using bracket notation in route)
}
