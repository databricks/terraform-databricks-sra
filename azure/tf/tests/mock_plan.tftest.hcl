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

run "plan_test_sat_broken_classic" {
  state_key       = "sat_broken_classic"
  command         = plan
  expect_failures = [var.allowed_fqdns]
  variables {
    sat_configuration = {
      enabled = true
    }
    allowed_fqdns    = []
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
    allowed_fqdns    = []
    hub_allowed_urls = []
  }
}

run "plan_test_sat_with_byosp" {
  state_key = "sat_byosp"
  command   = plan
  variables {
    allowed_fqdns = ["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"]
    sat_configuration = {
      enabled = true
    }
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
      enabled           = true
      proxies           = { "http_proxy" : "http://localhost:80" }
      run_on_serverless = false
      schema_name       = "notsat"
      catalog_name      = "notsat"
    }
  }
}

run "plan_test_byo_hub_with_spoke" {
  state_key = "byo_hub_with_spoke"
  command   = plan
  variables {
    create_hub              = false
    databricks_metastore_id = "00000000-0000-0000-0000-000000000000"
    resource_suffix         = "spoke"
    tags                    = { example = "value" }

    # Create SRA-managed workspace vnet
    workspace_vnet = {
      cidr     = "10.0.2.0/24"
      new_bits = null
    }

    # BYO hub integration
    # Note: spoke.tf references existing_hub_vnet which may need to be defined
    hub_settings = {
      ncc_id                  = "mock-ncc-id"
      ncc_name                = "mock-ncc"
      key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
      managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      network_policy_id       = "mock-policy-id"
    }

    # Provide existing hub vnet info if needed
    existing_hub_vnet = {
      route_table_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/routeTables/rt-external"
      vnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/virtualNetworks/vnet-external-hub"
    }
  }
}

run "plan_test_byo_hub_byo_network" {
  state_key = "byo_hub_byo_network"
  command   = plan
  variables {
    create_hub              = false
    databricks_metastore_id = "00000000-0000-0000-0000-000000000000"
    create_workspace_vnet   = false
    resource_suffix         = "spokenonet"
    tags                    = { test = "value" }
    sat_configuration = {
      enabled = false
    }
    workspace_vnet = null
    # BYO workspace vnet
    existing_workspace_vnet = {
      network_configuration = {
        virtual_network_id                                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
        private_subnet_id                                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/container"
        public_subnet_id                                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/host"
        private_subnet_network_security_group_association_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/container"
        public_subnet_network_security_group_association_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/host"
        private_endpoint_subnet_id                           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/privatelink"
      }
      dns_zone_ids = {
        backend = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.azuredatabricks.net"
        dfs     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
        blob    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
      }
    }

    # Use existing resource group
    existing_resource_group_name = "rg-test"

    # BYO hub integration
    hub_settings = {
      ncc_id                  = "mock-ncc-id"
      ncc_name                = "mock-ncc"
      key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
      managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      network_policy_id       = "mock-policy-id"
    }
  }
}

run "plan_test_cmk_disabled" {
  state_key = "cmk_disabled"
  command   = plan
  variables {
    resource_suffix = "nocmk"
    cmk_enabled     = false
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }
}

run "plan_test_enhanced_security" {
  state_key = "enhanced_security"
  command   = plan
  variables {
    resource_suffix = "secure"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
    workspace_security_compliance = {
      automatic_cluster_update_enabled      = true
      compliance_security_profile_enabled   = true
      compliance_security_profile_standards = ["HIPAA", "PCI_DSS"]
      enhanced_security_monitoring_enabled  = true
    }
  }
}

run "plan_test_byo_resource_group" {
  state_key = "byo_rg"
  command   = plan
  variables {
    create_workspace_resource_group = false
    existing_resource_group_name    = "rg-existing"
    resource_suffix                 = "byorg"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }
}

run "plan_test_name_overrides" {
  state_key = "name_overrides"
  command   = plan
  variables {
    resource_suffix = "custom"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
    workspace_name_overrides = {
      databricks_workspace = "my-custom-workspace"
      private_endpoint     = "pe-custom-databricks"
    }
  }
}

run "plan_test_custom_subnet_sizing" {
  state_key = "custom_subnets"
  command   = plan
  variables {
    resource_suffix = "customsubs"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = 3
    }
  }
}
