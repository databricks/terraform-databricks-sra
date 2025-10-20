variable "databricks_host" {
  type        = string
  description = "Databricks workspace host"
}

variable "tags" {
  type        = map(string)
  description = "Tags to use for all resources"
}
