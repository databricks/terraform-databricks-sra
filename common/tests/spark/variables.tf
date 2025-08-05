variable "databricks_host" {
  type        = string
  description = "Databricks workspace host"
}

variable "tags" {
  type        = map(string)
  description = "Tags to use for all resources"
}

variable "cluster_id" {
  type        = string
  description = "Cluster to use for jobs"
  # If this variable is set to null, it becomes a serverless job
  nullable = true
}
