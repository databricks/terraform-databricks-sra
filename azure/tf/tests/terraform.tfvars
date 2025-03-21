databricks_account_id = "databricks-account-id"
location              = "eastus2"
hub_vnet_cidr         = "10.0.0.0/23"
hub_resource_suffix   = "test"
spoke_config = {
<<<<<<< HEAD
<<<<<<< HEAD
  spoke = {
    resource_suffix = "spoke"
=======
  spoke_a = {
    resource_suffix = "spokea"
>>>>>>> b0be3c5 (tests(azure): Reenable tags checking, require terraform fmt in tests)
=======
  spoke = {
    resource_suffix = "spoke"
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
    cidr            = "10.0.2.0/24"
    tags = {
      example = "value"
    }
  }
<<<<<<< HEAD
<<<<<<< HEAD
=======
  spoke_b = {
    resource_suffix = "spokeb"
    cidr            = "10.0.3.0/24"
    tags = {
      example = "value"
    }
  }
>>>>>>> b0be3c5 (tests(azure): Reenable tags checking, require terraform fmt in tests)
=======
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
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
