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

variable "analysis_schema_name" {
  description = "Name of the schema to be used for analysis"
  type        = string
}

variable "databricks_account_id" {
  description = "ID of the Databricks account"
  type        = string
  sensitive   = true
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
