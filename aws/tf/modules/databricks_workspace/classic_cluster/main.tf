# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster

# Cluster Version
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

# Cluster Creation
resource "databricks_cluster" "example" {
  cluster_name            = "Standard Classic Compute Plane Cluster"
  data_security_mode      = "USER_ISOLATION"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = var.region == "us-gov-west-1" ? "i3en.xlarge" : "i3.xlarge"
  autotermination_minutes = 10

  autoscale {
    min_workers = 1
    max_workers = 2
  }

  # Custom Tags
  custom_tags = {
    "Project" = var.resource_prefix
  }
}