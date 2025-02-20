# Define a variable to store the title-cased location
locals {
  title_cased_location = title(var.location)

  # Define a map to store service tags with their corresponding values
  service_tags = {
    "sql" : "Sql.${local.title_cased_location}",
    "storage" : "Storage.${local.title_cased_location}",
    "eventhub" : "EventHub.${local.title_cased_location}"
  }

  # Define a regular expression pattern to extract subscription ID and resource group from the resource group ID
  # resource_regex = "/subscriptions/(.+)/resourceGroups/(.+)"

  # Extract the subscription ID using the regular expression pattern
  # subscription_id = regex(local.resource_regex, azurerm_resource_group.this.id)[0]

  # Extract the resource group using the regular expression pattern
  # resource_group = regex(local.resource_regex, azurerm_resource_group.this.id)[1]

  # Get the tenant ID from the current Azure client configuration
  tenant_id = data.azurerm_client_config.current.tenant_id

  subnet_map = var.subnet_map

}
