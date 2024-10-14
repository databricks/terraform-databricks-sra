mock_provider "azurerm" {}

run "null_resource_trigger_default" {
  command = plan
}
