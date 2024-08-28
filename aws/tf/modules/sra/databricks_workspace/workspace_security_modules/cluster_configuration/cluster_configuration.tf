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
      "value" : 10,
      "hidden" : true
    },
    "custom_tags.Project" : {
      "type" : "fixed",
      "value" : var.resource_prefix
    },
    "spark_conf.spark.hadoop.javax.jdo.option.ConnectionURL" : null,
    "spark_conf.spark.hadoop.javax.jdo.option.ConnectionDriverName" : null,
    "spark_conf.spark.hadoop.javax.jdo.option.ConnectionUserName" : null,
    "spark_conf.spark.hadoop.javax.jdo.option.ConnectionPassword" : null
  }

  isolated_policy = merge(
    local.default_policy,
    {
      "spark_conf.spark.hadoop.javax.jdo.option.ConnectionURL" : {
        "type" : "fixed",
        "value" : "jdbc:derby:memory:myInMemDB;create=true"
      },
      "spark_conf.spark.hadoop.javax.jdo.option.ConnectionDriverName" : {
        "type" : "fixed",
        "value" : "org.apache.derby.jdbc.EmbeddedDriver"
      },
      "spark_conf.spark.hadoop.javax.jdo.option.ConnectionUserName" : {
        "type" : "fixed",
        "value" : "<This is optional>"
      },
      "spark_conf.spark.hadoop.javax.jdo.option.ConnectionPassword" : {
        "type" : "fixed",
        "value" : "<This is optional>"
      }
    }
  )

  selected_policy = var.operation_mode == "Isolated" ? local.default_policy : local.isolated_policy

  final_policy = { for k, v in local.selected_policy : k => v if v != null }
}

resource "databricks_cluster_policy" "example" {
  name       = "Example Cluster Policy"
  definition = jsonencode(local.final_policy)
}

// Cluster Creation
resource "databricks_cluster" "example" {
  cluster_name            = "Shared Cluster"
  data_security_mode      = "USER_ISOLATION"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = var.compliance_security_profile_egress_ports ? "i3en.xlarge" : "i3.xlarge"
  policy_id               = databricks_cluster_policy.example.id
  autotermination_minutes = 10

  autoscale {
    min_workers = 1
    max_workers = 2
  }

  spark_conf = {
    "secret.example" = var.secret_config_reference
  }

  depends_on = [
    databricks_cluster_policy.example
  ]
}