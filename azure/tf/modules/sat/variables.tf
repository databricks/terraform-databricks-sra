variable "service_principal_client_id" {
  type        = string
  description = "Client ID of Azure Service Principal to use for SAT"
}

variable "service_principal_client_secret" {
  type        = string
  description = "Client secret of Azure Service Principal to use for SAT"
}

variable "schema_name" {
  type        = string
  description = "Name of the schema to create for SAT"
}

variable "catalog_name" {
  type        = string
  description = "Name of the catalog to create for SAT"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "proxies" {
  type        = map(any)
  default     = {}
  description = "Proxies config to use for SAT"
}

variable "run_on_serverless" {
  type        = bool
  default     = false
  description = "Whether to run SAT on serverless"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "workspace_id" {
  type        = string
  description = "Databricks Workspace ID"
}

variable "external_location_url" {
  type        = string
  description = "URL for external location"
}

variable "uc_credential_name" {
  type        = string
  description = "Name of the storage credential created for UC"
}
