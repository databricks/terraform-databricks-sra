databricks_account_id = "databricks-account-id"
location              = "eastus2"
hub_vnet_cidr         = "10.0.0.0/23"
hub_resource_suffix   = "test"
resource_suffix       = "spoke"
workspace_vnet = {
  cidr = "10.0.2.0/24"
}
tags = {
  example = "value"
}
subscription_id = "00000"
