# Get the latest Spark version
data "databricks_spark_version" "latest" {
  long_term_support = true
}

# Get the smallest available node type for the cloud provider
data "databricks_node_type" "smallest" {
  min_cores = 3
  local_disk = true
}

resource "databricks_cluster" "test_cluster" {
  cluster_name  = "SRA Test Cluster"
  node_type_id  = data.databricks_node_type.smallest.id
  spark_version = data.databricks_spark_version.latest.id
  autoscale {
    min_workers = 1
    max_workers = 2
  }
  data_security_mode      = "SINGLE_USER"
  autotermination_minutes = 30
  custom_tags             = var.tags
}
