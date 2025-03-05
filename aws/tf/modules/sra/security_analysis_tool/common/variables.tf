variable "account_console_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "sqlw_id" {
  type        = string
  description = "16 character SQL Warehouse ID: Type new to have one created or enter an existing SQL Warehouse ID"
  validation {
    condition     = can(regex("^(new|[a-f0-9]{16})$", var.sqlw_id))
    error_message = "Format 16 characters (0-9 and a-f). For more details reference: https://docs.databricks.com/administration-guide/account-api/iam-role.html."
  }
  default = "new"
}

variable "secret_scope_name" {
  description = "Name of secret scope for SAT secrets"
  type        = string
  default     = "sat_scope"
}

variable "notification_email" {
  type        = string
  description = "Optional user email for notifications. If not specified, current user's email will be used"
  default     = ""
}

<<<<<<< HEAD
=======
variable "gcp_impersonate_service_account" {
  type        = string
  description = "GCP Service Account to impersonate (e.g. xyz-sa-2@project.iam.gserviceaccount.com)"
  default     = ""
}

>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
variable "analysis_schema_name" {
  type        = string
  description = "Name of the schema to be used for analysis"
}

variable "proxies" {
<<<<<<< HEAD
  type        = map
=======
  type        = map(any)
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
  description = "Proxies to be used for Databricks API calls"
}

variable "run_on_serverless" {
  type        = bool
  description = "Flag to run SAT initializer/Driver on Serverless"
}
