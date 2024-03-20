data "databricks_current_user" "me" {}

data "databricks_node_type" "smallest" {
  local_disk            = true
  min_cores             = 4
  gb_per_core           = 8
  photon_worker_capable = true
  photon_driver_capable = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}
