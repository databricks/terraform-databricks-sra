# ----------------------------------------------------------------------------
# Azure variables
# ----------------------------------------------------------------------------
variable "service_principal_client_id" {
  type        = string
  description = "(Required) Client ID of Azure Service Principal to use for SAT"
}

variable "service_principal_client_secret" {
  type        = string
  description = "(Required) Client secret of Azure Service Principal to use for SAT"
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "(Required) Azure tenant ID"
}

# ----------------------------------------------------------------------------
# Databricks variables
# ----------------------------------------------------------------------------
variable "schema_name" {
  type        = string
  description = "(Required) Name of the schema to create for SAT"
}

variable "catalog_name" {
  type        = string
  description = "(Required) Name of the catalog to use for SAT"
}

variable "run_on_serverless" {
  type        = bool
  default     = false
  description = "(Optional) Whether to run SAT on serverless"
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}

variable "workspace_id" {
  type        = string
  description = "(Required) Databricks Workspace ID"
}

variable "proxies" {
  type        = map(any)
  default     = {}
  description = "(Optional) Proxies config to use for SAT"
}
