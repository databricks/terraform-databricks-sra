variable "sa_name" {
  description = "The name of the service account"
  type        = string
  default     = "databricks-workspace-creator"
}

variable "project" {
  type = string
}

variable "delegate_from" {
  type    = list(string)
  default = []
}

variable "create_service_account_key" {
  # SECURITY: defaults to false. Long-lived JSON keys are written to disk and
  # stored in Terraform state; prefer impersonation / Workload Identity
  # Federation. Set to true only if a key file is strictly required.
  description = "Whether to create a service account key for authentication (discouraged; prefer impersonation)."
  type        = bool
  default     = false
}