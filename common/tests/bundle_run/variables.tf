variable "databricks_host" {
  type        = string
  description = "Host to use for testing"
}

variable "open_test_job" {
  type        = bool
  description = "Open test job in browser on creation"
  default     = false
}

variable "bundle_job_name" {
  type        = string
  description = "Name of the job within a bundle, NOT the actual job name in the workspace"
}

variable "environment" {
  type        = map(string)
  description = "Environment variable map for all bundle commands"
}

variable "working_dir" {
  type        = string
  description = "Directory to run bundle commands from (should contain databricks.yml file)"
}

variable "depends" {
  type        = string
  description = "An unused variable used for creating a dependency graph"
  default     = ""
}
