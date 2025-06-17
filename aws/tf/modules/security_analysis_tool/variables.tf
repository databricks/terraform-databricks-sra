# Authentication Variables

variable "account_pass" {
  description = "Account Console Password"
  type        = string
  default     = " "
}

variable "account_user" {
  description = "Account Console Username"
  type        = string
  default     = " "
}

variable "client_id" {
  description = "Service Principal Application (client) ID"
  type        = string
  default     = "value"
}

variable "client_secret" {
  description = "SP Secret"
  type        = string
  default     = "value"
}

variable "use_sp_auth" {
  description = "Authenticate with Service Principal OAuth tokens instead of user and password"
  type        = bool
  default     = true
}

# Databricks Variables

variable "account_console_id" {
  description = "Databricks Account Console ID"
  type        = string
}

variable "analysis_schema_name" {
  description = "Name of the schema to be used for analysis"
  type        = string
}

variable "catalog_name" {
  description = "Name of the catalog for the security analysis tool"
  type        = string
}

variable "databricks_account_id" {
  description = "ID of the Databricks account"
  type        = string
  sensitive   = true
}

variable "schema_name" {
  description = "Name of the schema for the security analysis tool"
  type        = string
}

variable "sqlw_id" {
  description = "16 character SQL Warehouse ID: Type new to have one created or enter an existing SQL Warehouse ID"
  type        = string
  default     = "new"
  validation {
    condition     = can(regex("^(new|[a-f0-9]{16})$", var.sqlw_id))
    error_message = "Format 16 characters (0-9 and a-f). For more details reference: https://docs.databricks.com/administration-guide/account-api/iam-role.html."
  }
}

variable "workspace_id" {
  description = "ID of the Databricks workspace"
  type        = string
}

# Configuration Variables

variable "proxies" {
  description = "Proxies to be used for Databricks API calls"
  type        = map(any)
}

variable "run_on_serverless" {
  description = "Flag to run SAT initializer/Driver on Serverless"
  type        = bool
}
