variable "sa_name" {
  description = "The name of the service account"
  type        = string
  default     = "databricks-workspace-creator"
  }

variable "project" {
  type    = string
}

variable "delegate_from" {
  type    = list(string)
  default = []
}

variable "create_service_account_key" {
  description = "Whether to create a service account key for authentication"
  type        = bool
  default     = true
}