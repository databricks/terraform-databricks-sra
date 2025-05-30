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
