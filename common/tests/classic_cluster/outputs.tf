output "cluster_id" {
  description = "Cluster ID"
  value       = databricks_cluster.test_cluster.cluster_id
}

output "node_type_id" {
  description = "Type of node used"
  value       = data.databricks_node_type.smallest.id
}

output "spark_version" {
  description = "Spark version used"
  value       = data.databricks_spark_version.latest.id
}
