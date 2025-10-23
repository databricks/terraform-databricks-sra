test {
  parallel = true
}

# The below mocked providers have mock_data blocks anywhere a properly formatted GUID is used in the configuration
# (i.e. access policies, role assignments, etc.)
mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000000"
      object_id = "00000000-0000-0000-0000-000000000000"
    }
  }
  mock_data "azurerm_subscription" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/container"
    }
  }
}

mock_provider "azuread" {
  mock_data "azuread_application_published_app_ids" {
    defaults = {
      result = {
        AzureDataBricks = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  mock_data "azuread_service_principal" {
    defaults = {
      object_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "databricks" {
  mock_data "databricks_user" {
    defaults = {
      id = 0
    }
  }
}

mock_provider "databricks" {
  alias = "SAT"
}

run "plan_test_defaults" {
  state_key = "defaults"
  command   = plan
}

run "plan_test_no_sat" {
  state_key = "no_sat"
  command   = plan
  variables {
    sat_configuration = {
      enabled = false
    }
    hub_allowed_urls = []
  }
}

run "plan_test_sat_broken_classic" {
  state_key       = "sat_broken_classic"
  command         = plan
  expect_failures = [var.public_repos]
  variables {
    sat_configuration = {
      enabled = true
    }
    public_repos     = []
    hub_allowed_urls = []
  }
}

run "plan_test_sat_broken_serverless" {
  state_key       = "sat_broken_serverless"
  command         = plan
  expect_failures = [var.hub_allowed_urls]
  variables {
    sat_configuration = {
      enabled           = true
      run_on_serverless = true
    }
    public_repos     = []
    hub_allowed_urls = []
  }
}

run "plan_test_sat_with_byosp" {
  state_key = "sat_byosp"
  command   = plan
  variables {
    sat_service_principal = {
      client_id     = ""
      client_secret = ""
    }
  }
}

run "plan_test_sat_nondefaults" {
  state_key = "sat_non_defaults"
  command   = plan
  variables {
    sat_configuration = {
      resource_suffix   = "spoke_b"
      proxies           = { "http_proxy" : "http://localhost:80" }
      run_on_serverless = false
      schema_name       = "notsat"
      catalog_name      = "notsat"
    }
  }
}

run "plan_test_byo_hub" {
  state_key = "byo_hub"
  command   = plan
  variables {
    create_hub = false
    sat_configuration = {
      enabled = false
    }
    workspace_config = {
      spoke = {
        spoke_name              = "spoke"
        ncc_id                  = "mock-ncc-id"
        ncc_name                = "mock-ncc"
        key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
        managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
        managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
        network_policy_id       = "mock-policy-id"
        metastore_id            = "mock-metastore-id"
      }
      spoke_no_network = {
        spoke_name              = null
        resource_suffix         = "spokenonet"
        resource_group_name     = "rg-test"
        ncc_id                  = "mock-ncc-id"
        ncc_name                = "mock-ncc"
        key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
        managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
        managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
        network_policy_id       = "mock-policy-id"
        metastore_id            = "mock-metastore-id"
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
    spoke_config = {
      spoke = {
        resource_suffix         = "spoke"
        cidr                    = "10.0.2.0/24"
        route_table_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external/providers/Microsoft.Network/routeTables/rt-external"
        ipgroup_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external/providers/Microsoft.Network/ipGroups/ipg-external"
        hub_vnet_name           = "vnet-external-hub"
        hub_resource_group_name = "rg-external-hub"
        hub_vnet_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/virtualNetworks/vnet-external-hub"
        tags                    = { example = "value" }
      }
    }
  }
}

run "plan_test_byo_spoke_network" {
  state_key = "byo_spoke_network"
  command   = plan
  variables {
    sat_configuration = {
      enabled = false
    }
    # Test that spoke_no_network workspace works with user-provided network config
    # The workspace_config in terraform.tfvars already has this configured
  }
}
