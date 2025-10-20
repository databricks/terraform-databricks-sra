variable "databricks_host" {
  type        = string
  description = "Host to use for testing"
}

variable "environment" {
  type        = map(string)
  description = "Environment variable map for all bundle commands"
}
