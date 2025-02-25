# The below mocked providers have mock_data blocks anywhere a properly formatted GUID is used in the configuration
# (i.e. access policies, role assignments, etc.)
mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000000"
      object_id = "00000000-0000-0000-0000-000000000000"
    }
  }
<<<<<<< HEAD
  mock_data "azurerm_subscription" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000"
=======
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
>>>>>>> 9ec052c (tests(azure): Update test to include new requirements)
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

mock_provider "databricks" {}

mock_provider "databricks" {
  alias = "SAT"
}

run "plan_test_defaults" {
  command = plan
}

<<<<<<< HEAD
run "plan_test_no_sat" {
  command = plan
  variables {
    sat_configuration = {
      enabled = false
    }
  }
}

run "plan_test_sat_with_byosp" {
  command = plan
  variables {
    sat_service_principal = {
      client_id     = ""
      client_secret = ""
    }
  }
}

run "plan_test_sat_nondefaults" {
  command = plan
  variables {
    sat_configuration = {
      resource_suffix   = "spoke_b"
      proxies           = { "http_proxy" : "http://localhost:80" }
      run_on_serverless = false
      schema_name       = "notsat"
      catalog_name      = "notsat"
    }
  }
=======
variables {
  databricks_account_id   = "databricks-account-id"
  location                = "eastus2"
  hub_vnet_cidr           = "10.0.0.0/23"
  hub_resource_group_name = "rg-hub"
  hub_vnet_name           = "vnet-hub"
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
>>>>>>> 9ec052c (tests(azure): Update test to include new requirements)
}
