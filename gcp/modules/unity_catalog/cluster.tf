

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

resource "databricks_cluster" "unity_sql" {
  provider = databricks.workspace
  cluster_name            = "Unity SQL"
  //spark_version           = data.databricks_spark_version.latest_lts.id
  spark_version = "11.3.x-scala2.12"
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 60
  enable_elastic_disk     = false
  num_workers             = 2
  policy_id               = databricks_cluster_policy.example.id
 
  data_security_mode = "USER_ISOLATION"
  # need to wait until the metastore is assigned
  depends_on = [
    databricks_metastore_assignment.this
  ]
}
