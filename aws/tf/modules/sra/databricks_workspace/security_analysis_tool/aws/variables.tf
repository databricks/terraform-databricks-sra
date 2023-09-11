variable "databricks_url" {
  description = "Should look like https://<workspace>.cloud.databricks.com"
  type        = string
}

variable "workspace_id" {
  description = "Should be the string of numbers in the workspace URL arg (e.g. https://<workspace>.cloud.databricks.com/?o=1234567890123456)"
  type        = string
}

variable "workspace_PAT" {
  description = "PAT should look like dapixxxxxxxxxxxxxxxxxxxx"
  type        = string
}

variable "account_console_id" {
  description = "Databricks Account Console ID"
  type        = string
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

### AWS Specific Variables

variable "account_user" {
  description = "Account Console Username"
  type        = string
}

variable "account_pass" {
  description = "Account Console Password"
  type        = string
}

variable "use_sp_auth" {
  description = "Authenticate with Service Principal OAuth tokens instead of user and password"
  type        = bool
  default     = false
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
