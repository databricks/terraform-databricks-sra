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
  node_type_id            = "m5n.large"
  autotermination_minutes = 10

  autoscale {
    min_workers = 1
    max_workers = 2
  }

  aws_attributes {
    availability     = "ON_DEMAND"
    ebs_volume_count = 1
    ebs_volume_size  = 32 # Size in GB, adjust as needed
    ebs_volume_type  = "GENERAL_PURPOSE_SSD"
  }

  # Unity Catalog only configuration
  spark_conf = {
    "spark.databricks.unityCatalogOnlyMode" : "true"
  }

  # Custom Tags
  custom_tags = {
    "Project" = var.resource_prefix
  }
}
