# Generate a random string for dbfsnaming
resource "random_string" "dbfsnaming" {
  special = false
  upper   = false
  length  = 13
}

# Define subnets using cidrsubnet function
locals {
  # Generate a random string for dbfs_name
  dbfs_name       = join("", ["dbstorage", random_string.dbfsnaming.result])
  managed_rg_name = join("", [module.naming.resource_group.name_unique, "adbmanaged"])

  # Serverless network
  serverless_internet_allowed_domains = [for dest in var.public_repos : dest if !startswith(dest, "*.")]
  serverless_internet_allowed_destinations = [
    for dest in local.serverless_internet_allowed_domains :
    {
      destination               = trimprefix(dest, "*."),
      internet_destination_type = "DNS_NAME"
    }
  ]

  # We use this to make sure that if we provision the 10th NCC in a region, that it does not cause subsequent terraform
  # plans/applies to fail due to the precondition on the NCC resource.
  ncc_name          = "ncc-${var.location}-${var.resource_suffix}"
  current_ncc_count = length([for k in data.databricks_mws_network_connectivity_configs.this.names : k if k != local.ncc_name])
  ncc_region_limit  = 10
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~>0.4"
  suffix  = [var.resource_suffix]
}

# Create the hub resource group
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location

  tags = var.tags
}

# Create the hub virtual network
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.hub_vnet_cidr]

  tags = var.tags
}

# Create the privatelink subnet
resource "azurerm_subnet" "privatelink" {
  name                 = "hub-privatelink"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.subnet_map["privatelink"]]
}

# Serverless Network
# Used to validate that there are enough NCCs left in a region
data "databricks_mws_network_connectivity_configs" "this" {
  region = var.location
}

# This NCC is shared across all workspaces created by SRA
resource "databricks_mws_network_connectivity_config" "this" {
  name   = local.ncc_name
  region = var.location

  lifecycle {
    precondition {
      condition     = local.current_ncc_count < local.ncc_region_limit
      error_message = "There are already ${local.ncc_region_limit} NCCs in ${var.location}!"
    }
  }
}

resource "databricks_account_network_policy" "restrictive_network_policy" {
  network_policy_id = "np-${var.resource_suffix}-restrictive"
  account_id        = var.databricks_account_id
  egress = {
    network_access = {
      restriction_mode              = "RESTRICTED_ACCESS"
      allowed_internet_destinations = local.serverless_internet_allowed_destinations
      policy_enforcement = {
        enforcement_mode = "ENFORCED"
      }
    }
  }
}
