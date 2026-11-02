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
    allowed_fqdns = ["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"]
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
    existing_ncc_id            = "mock-ncc-id"
    existing_ncc_name          = "mock-ncc"
    existing_network_policy_id = "mock-policy-id"
    existing_cmk_ids = {
      key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
      managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
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

    existing_ncc_id            = "mock-ncc-id"
    existing_ncc_name          = "mock-ncc"
    existing_network_policy_id = "mock-policy-id"
    existing_cmk_ids = {
      key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
      managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
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

# Azure Government requires only azure_environment — every endpoint derives from it.
run "plan_test_azure_gov" {
  state_key = "azure_gov"
  command   = plan
  variables {
    azure_environment = "usgovernment"
    location          = "usgovvirginia"
    resource_suffix   = "gov"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }

  assert {
    condition     = local.databricks_account_host == "https://accounts.usgov.databricks.azure.us"
    error_message = "Azure Government account console host was not derived from azure_environment"
  }

  assert {
    condition = local.private_dns_zone_names == {
      backend   = "privatelink.usgov.databricks.azure.us"
      dfs       = "privatelink.dfs.core.usgovcloudapi.net"
      blob      = "privatelink.blob.core.usgovcloudapi.net"
      key_vault = "privatelink.vaultcore.usgovcloudapi.net"
    }
    error_message = "Azure Government private DNS zone names were not derived from azure_environment"
  }
}

# The Commercial defaults must stay byte-identical to the values that were previously hardcoded.
run "plan_test_azure_public_defaults" {
  state_key = "azure_public_defaults"
  command   = plan
  variables {
    resource_suffix = "pub"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }

  assert {
    condition     = local.databricks_account_host == "https://accounts.azuredatabricks.net"
    error_message = "Azure Commercial account console host changed"
  }

  assert {
    condition = local.private_dns_zone_names == {
      backend   = "privatelink.azuredatabricks.net"
      dfs       = "privatelink.dfs.core.windows.net"
      blob      = "privatelink.blob.core.windows.net"
      key_vault = "privatelink.vaultcore.azure.net"
    }
    error_message = "Azure Commercial private DNS zone names changed"
  }
}

# Dashed suffixes must still yield valid (dash-free) storage account names for the hub (SAT) and spoke catalogs.
run "plan_test_dashed_resource_suffixes" {
  state_key = "dashed_resource_suffixes"
  command   = plan
  variables {
    hub_resource_suffix = "sra-hub"
    resource_suffix     = "dbx-dev"
    allowed_fqdns       = ["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"]
    sat_configuration = {
      enabled = true
    }
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }

  assert {
    condition     = module.spoke_catalog.storage_account_name == "stdbxdevuc"
    error_message = "Spoke catalog storage account name must have dashes stripped from resource_suffix"
  }

  assert {
    condition     = module.hub_catalog[0].storage_account_name == "stsrahubsatuc"
    error_message = "Hub (SAT) catalog storage account name must have dashes stripped from hub_resource_suffix"
  }
}

# Long suffixes must be truncated to Azure/Databricks name limits rather than failing the plan.
run "plan_test_long_resource_suffixes" {
  state_key = "long_resource_suffixes"
  command   = plan
  variables {
    hub_resource_suffix = "abcdefghijklmnopqrstuvwxyz0123"
    resource_suffix     = "zyxwvutsrqponmlkjihgfedcba9876"
    allowed_fqdns       = ["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"]
    sat_configuration = {
      enabled = true
    }
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }

  assert {
    condition     = length(module.spoke_catalog.storage_account_name) <= 24 && endswith(module.spoke_catalog.storage_account_name, "uc")
    error_message = "Spoke catalog storage account name must be at most 24 characters and keep the uc suffix"
  }

  assert {
    condition     = length(module.hub_catalog[0].storage_account_name) <= 24 && endswith(module.hub_catalog[0].storage_account_name, "uc")
    error_message = "Hub (SAT) catalog storage account name must be at most 24 characters and keep the uc suffix"
  }

  assert {
    condition     = length(module.hub[0].ncc_name) <= 30 && !endswith(module.hub[0].ncc_name, "-")
    error_message = "NCC name must be at most 30 characters and must not end with a dash"
  }
}

# Undashed suffixes must produce the same storage account names as before the dash fix.
run "plan_test_undashed_storage_names_unchanged" {
  state_key = "undashed_storage_names_unchanged"
  command   = plan

  assert {
    condition     = module.spoke_catalog.storage_account_name == "stspokeuc"
    error_message = "Spoke catalog storage account name changed for an undashed resource_suffix"
  }
}

# SAT depends on the serverless hub workspace, which is skipped in Azure Government.
run "plan_test_azure_gov_sat_rejected" {
  state_key       = "azure_gov_sat_rejected"
  command         = plan
  expect_failures = [var.sat_configuration]
  variables {
    azure_environment = "usgovernment"
    location          = "usgovvirginia"
    allowed_fqdns     = ["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"]
    sat_configuration = {
      enabled = true
    }
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }
}

# An unsupported cloud must be rejected.
run "plan_test_azure_environment_invalid" {
  state_key       = "azure_environment_invalid"
  command         = plan
  expect_failures = [var.azure_environment]
  variables {
    azure_environment = "usgovernmentl5"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
  }
}

# Context-based ingress control is off by default, so SRA-managed network policies get no ingress configuration.
run "plan_test_ingress_control_default_off" {
  state_key = "ingress_control_default_off"
  command   = plan

  assert {
    condition     = local.network_policy_ingress == null && local.network_policy_ingress_dry_run == null
    error_message = "Ingress control must not be configured unless workspace_ingress_control.enabled is true"
  }
}

# Enforced ingress restricts public access on the hub-managed network policies to the allowed IP ranges.
run "plan_test_ingress_control_enforced" {
  state_key = "ingress_control_enforced"
  command   = plan
  variables {
    resource_suffix = "ingress"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
    workspace_ingress_control = {
      enabled           = true
      allowed_ip_ranges = ["203.0.113.0/24", "198.51.100.10"]
    }
  }

  assert {
    condition     = local.network_policy_ingress.public_access.restriction_mode == "RESTRICTED_ACCESS"
    error_message = "Enforced ingress must restrict public access"
  }

  assert {
    condition     = local.network_policy_ingress.public_access.allow_rules[0].origin.included_ip_ranges.ip_ranges == tolist(["203.0.113.0/24", "198.51.100.10"])
    error_message = "Enforced ingress must allow only the configured IP ranges"
  }

  assert {
    condition     = local.network_policy_ingress_dry_run == null
    error_message = "Dry run ingress must not be set when dry_run is false"
  }
}

# Dry run ingress on the BYO-hub spoke policy writes the rules to ingress_dry_run and leaves ingress unset.
run "plan_test_ingress_control_dry_run_byo_hub" {
  state_key = "ingress_control_dry_run_byo_hub"
  command   = plan
  variables {
    create_hub                  = false
    create_spoke_network_policy = true
    databricks_metastore_id     = "00000000-0000-0000-0000-000000000000"
    resource_suffix             = "ingressbyo"
    workspace_vnet = {
      cidr     = "10.0.2.0/24"
      new_bits = null
    }
    existing_ncc_id   = "mock-ncc-id"
    existing_ncc_name = "mock-ncc"
    existing_cmk_ids = {
      key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
      managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
    }
    existing_hub_vnet = {
      route_table_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/routeTables/rt-external"
      vnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/virtualNetworks/vnet-external-hub"
    }
    workspace_ingress_control = {
      enabled           = true
      dry_run           = true
      allowed_ip_ranges = ["203.0.113.0/24"]
    }
  }

  assert {
    condition     = databricks_account_network_policy.spoke[0].ingress == null
    error_message = "Dry run must not enforce ingress on the spoke network policy"
  }

  assert {
    condition     = databricks_account_network_policy.spoke[0].ingress_dry_run.public_access.allow_rules[0].origin.included_ip_ranges.ip_ranges == tolist(["203.0.113.0/24"])
    error_message = "Dry run must apply the configured IP ranges to ingress_dry_run on the spoke network policy"
  }
}

# Enabling ingress control without any allowed IP ranges would deny all public access, so it is rejected.
run "plan_test_ingress_control_requires_ip_ranges" {
  state_key       = "ingress_control_requires_ip_ranges"
  command         = plan
  expect_failures = [var.workspace_ingress_control]
  variables {
    workspace_ingress_control = {
      enabled = true
    }
  }
}

# Only IPv4 addresses and CIDRs are supported by context-based ingress.
run "plan_test_ingress_control_rejects_invalid_ranges" {
  state_key       = "ingress_control_rejects_invalid_ranges"
  command         = plan
  expect_failures = [var.workspace_ingress_control]
  variables {
    workspace_ingress_control = {
      enabled           = true
      allowed_ip_ranges = ["2001:db8::/32", "not-an-ip"]
    }
  }
}

# Context-based ingress control is not available in Azure Government.
run "plan_test_ingress_control_rejected_in_gov" {
  state_key       = "ingress_control_rejected_in_gov"
  command         = plan
  expect_failures = [var.workspace_ingress_control]
  variables {
    azure_environment = "usgovernment"
    location          = "usgovvirginia"
    workspace_vnet = {
      cidr     = "10.1.0.0/20"
      new_bits = null
    }
    workspace_ingress_control = {
      enabled           = true
      allowed_ip_ranges = ["203.0.113.0/24"]
    }
  }
}

# BYO hub with an existing network policy has no SRA-managed policy to attach ingress rules to, so it is rejected.
run "plan_test_ingress_control_rejected_with_existing_policy" {
  state_key       = "ingress_control_rejected_with_existing_policy"
  command         = plan
  expect_failures = [var.workspace_ingress_control]
  variables {
    create_hub                 = false
    databricks_metastore_id    = "00000000-0000-0000-0000-000000000000"
    resource_suffix            = "ingressexisting"
    existing_ncc_id            = "mock-ncc-id"
    existing_ncc_name          = "mock-ncc"
    existing_network_policy_id = "mock-policy-id"
    existing_cmk_ids = {
      key_vault_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.KeyVault/vaults/mock-kv"
      managed_disk_key_id     = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
      managed_services_key_id = "https://example-keyvault.vault.azure.net/keys/example/fdf067c93bbb4b22bff4d8b7a9a56217"
    }
    existing_hub_vnet = {
      route_table_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/routeTables/rt-external"
      vnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-external-hub/providers/Microsoft.Network/virtualNetworks/vnet-external-hub"
    }
    workspace_ingress_control = {
      enabled           = true
      allowed_ip_ranges = ["203.0.113.0/24"]
    }
  }
}
