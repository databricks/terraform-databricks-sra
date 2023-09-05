

data "databricks_node_type" "smallest" {
  local_disk = true
}

// Cluster Version
# data "databricks_spark_version" "latest_lts" {
#   long_term_support = true
# }

// Example Cluster Policy
locals {
  default_policy = {
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 60,
      "hidden" : true
    },
    "custom_tags.Example" : {
      "type" : "fixed",
      "value" : var.resource_prefix
    }
  }
}

resource "databricks_cluster_policy" "example" {
  provider = databricks.workspace
  name       = "Example Cluster Policy"
  definition = jsonencode(local.default_policy)
}