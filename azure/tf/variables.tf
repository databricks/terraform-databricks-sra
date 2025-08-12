variable "databricks_account_id" {
  type        = string
  description = "(Required) The Databricks account ID target for account-level operations"
}
variable "location" {
  type        = string
  description = "(Required) The Azure region for the hub and spoke deployment"
}

variable "hub_vnet_cidr" {
  type        = string
  description = "(Required) The CIDR block for the hub Virtual Network"
}

variable "hub_resource_suffix" {
  type        = string
  description = "(Required) Resource suffix for naming resources in hub"
}

variable "public_repos" {
  type        = list(string)
  description = "(Optional) List of public repository IP addresses to allow access to."
  default     = ["python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org", "cran.r-project.org", "*.cran.r-project.org", "r-project.org"]
}

variable "hub_allowed_urls" {
  type        = set(string)
  description = "(Optional) List of URLs to allow the hub workspace access to."
  default     = ["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"]

  validation {
    condition     = var.sat_configuration.enabled ? length(setsubtract(["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"], var.hub_allowed_urls)) == 0 : true
    error_message = "Since SAT is enabled, you must include SAT-required URLs in the hub_allowed_urls variable."
  }
}

variable "spoke_config" {
  type = map(object(
    {
      resource_suffix          = string
      cidr                     = string
      tags                     = map(string)
      is_unity_catalog_enabled = optional(bool, true)
      storage_account_name     = optional(string, null)
    }
  ))
  description = "(Required) List of spoke configurations"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "databricks_metastore_id" {
  type        = string
  default     = ""
  description = "Required if is_unity_catalog_enabled = false"
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure Subscription ID to deploy into"
}

variable "sat_configuration" {
  type = object({
    enabled           = optional(bool, true)
    schema_name       = optional(string, "sat")
    catalog_name      = optional(string, "sat")
    resource_suffix   = optional(string, "null")
    proxies           = optional(map(any), {})
    run_on_serverless = optional(bool, true)
  })
  default     = {}
  description = "(Optional) Configuration for the SAT customization"
}

variable "sat_service_principal" {
  type = object({
    client_id     = optional(string, "")
    client_secret = optional(string, "")
    name          = optional(string, "spSAT")
  })
  default = {}
  validation {
    condition     = var.sat_service_principal.client_id == "" && var.sat_service_principal.client_secret == "" || var.sat_service_principal.client_id != "" && var.sat_service_principal.client_secret != ""
    error_message = "Both a client_id and client_secret must be provided for SAT if either are provided"
  }
  description = "(Optional) Service principal configuration for running SAT. If this is not provided, a service principal will be created. The created service principal name can be configured with the name field in this variable."
  sensitive   = true
}

# This variable is only used for development purposes - is should not be used/set if deploying SRA in a customer environment
variable "sat_force_destroy" {
  type        = bool
  default     = false
  description = "Used to allow Terraform to force destroy the SAT catalog. This is only used for testing SRA."
}
