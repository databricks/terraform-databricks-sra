// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster

// Cluster Version
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

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
  name       = "Example Cluster Policy"
  definition = jsonencode(local.default_policy)
}

// Cluster Creation
resource "databricks_cluster" "example" {
  cluster_name       = "Shared Cluster"
  data_security_mode = "USER_ISOLATION"
  spark_version      = data.databricks_spark_version.latest_lts.id
  node_type_id       = "i3.xlarge"
  policy_id          = databricks_cluster_policy.example.id
  autoscale {
    min_workers = 1
    max_workers = 8
  }
  spark_conf = {
    # ...
    "secret.example" = var.secret_config_reference
  }
  depends_on = [
    databricks_cluster_policy.example
  ]
}
