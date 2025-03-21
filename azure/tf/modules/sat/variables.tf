<<<<<<< HEAD
<<<<<<< HEAD
# ----------------------------------------------------------------------------
# Azure variables
# ----------------------------------------------------------------------------
variable "service_principal_client_id" {
  type        = string
  description = "(Required) Client ID of Azure Service Principal to use for SAT"
=======
variable "service_principal_client_id" {
  type        = string
  description = "Client ID of Azure Service Principal to use for SAT"
>>>>>>> d83f047 (feat(azure): Add support for SAT)
=======
# ----------------------------------------------------------------------------
# Azure variables
# ----------------------------------------------------------------------------
variable "service_principal_client_id" {
  type        = string
  description = "(Required) Client ID of Azure Service Principal to use for SAT"
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
}

variable "service_principal_client_secret" {
  type        = string
<<<<<<< HEAD
<<<<<<< HEAD
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
=======
  description = "Client secret of Azure Service Principal to use for SAT"
}

variable "schema_name" {
  type        = string
  description = "Name of the schema to create for SAT"
>>>>>>> d83f047 (feat(azure): Add support for SAT)
}

variable "catalog_name" {
  type        = string
<<<<<<< HEAD
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
=======
  description = "Name of the catalog to create for SAT"
=======
  description = "(Required) Client secret of Azure Service Principal to use for SAT"
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure subscription ID"
}

variable "tenant_id" {
  type        = string
<<<<<<< HEAD
  description = "Azure tenant ID"
>>>>>>> d83f047 (feat(azure): Add support for SAT)
}

variable "proxies" {
  type        = map(any)
  default     = {}
<<<<<<< HEAD
  description = "(Optional) Proxies config to use for SAT"
=======
  description = "Proxies config to use for SAT"
=======
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
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
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
<<<<<<< HEAD
  description = "Databricks Workspace ID"
>>>>>>> d83f047 (feat(azure): Add support for SAT)
=======
  description = "(Required) Databricks Workspace ID"
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
}

variable "proxies" {
  type        = map(any)
  default     = {}
  description = "(Optional) Proxies config to use for SAT"
}
