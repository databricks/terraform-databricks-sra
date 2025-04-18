# The below mocked providers have mock_data blocks anywhere a properly formatted GUID is used in the configuration
# (i.e. access policies, role assignments, etc.)
mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000000"
      object_id = "00000000-0000-0000-0000-000000000000"
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

run "plan_test" {
  command = plan
}

variables {
  databricks_account_id   = "databricks-account-id"
  location                = "eastus2"
  hub_vnet_cidr           = "10.0.0.0/23"
  hub_resource_group_name = "rg-hub"
  hub_resource_suffix     = "test"
  spoke_config = {
    spoke_a = {
      resource_suffix = "spokea"
      cidr            = "10.0.2.0/24"
      tags = {
        example = "value"
      }
    }
  }
  subscription_id = "00000"
}
