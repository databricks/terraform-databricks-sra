databricks_account_id = "databricks-account-id"
location              = "eastus2"
hub_vnet_cidr         = "10.0.0.0/23"
hub_resource_suffix   = "test"
spoke_config = {
  spoke = {
    resource_suffix = "spoke"
    cidr            = "10.0.2.0/24"
    tags = {
      example = "value"
    }
  }
}
tags = {
  example = "value"
}
subscription_id = "00000"
sat_configuration = {
  enabled                = true
  service_principal_name = "sattst"
  spoke                  = "spoke_a"
  schema_name            = "sat"
}
workspace_config = {
  webauth = {
    spoke_name = null
  }
  spoke = {
    spoke_name = "spoke"
  }
  spoke_no_network = {
    spoke_name          = null
    resource_suffix     = "spokenonet"
    resource_group_name = "rg-test"
    network_configuration = {
      virtual_network_name                                 = "vnet-test"
      private_subnet_name                                  = "container"
      public_subnet_name                                   = "host"
      private_subnet_network_security_group_association_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/container"
      public_subnet_network_security_group_association_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/host"
      private_endpoint_subnet_name                         = "private-endpoints"
    }
    dns_zone_ids = {
      dfs     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
      blob    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
      backend = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.azuredatabricks.net"
    }
    tags = { test = "value" }
  }
}
