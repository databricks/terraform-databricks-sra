<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
variable "application_id" {
  type        = string
  description = "(Required) Application ID in Hub unitycatalog.tf"
}
>>>>>>> 900395d (naming)
=======
# variable "application_id" {
#   type        = string
#   description = "(Required) Application ID in Hub unitycatalog.tf"
# }
>>>>>>> 6df143a (deployed without UC)
=======
>>>>>>> 2531551 (chore: Remove commented code)
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
<<<<<<< HEAD
  description = "(Required) Resource suffix for naming resources in hub"
=======
  description = "(Required) The name for the hub Resource Group"
>>>>>>> bba9fc9 (remove vnet naming option in the hub to standardize approach, add example tfvars)
}

variable "hub_storage_account_name" {
  type        = string
  description = "(Optional) Name of the storage account created in hub (the metastore root storage account), will be generated if not provided"
  default     = null
}

variable "hub_resource_suffix" {
  type        = string
  description = "(Optional} Resource suffix for naming resources in hub, 'hub' is used if not provided"
  default     = "hub"
}

variable "public_repos" {
  type        = list(string)
  description = "(Optional) List of public repository IP addresses to allow access to."
  default     = ["python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org", "cran.r-project.org", "*.cran.r-project.org", "r-project.org"]
}

variable "spoke_config" {
  type = map(object(
    {
<<<<<<< HEAD
      resource_suffix          = string
      cidr                     = string
      tags                     = map(string)
      is_unity_catalog_enabled = optional(bool, true)
      storage_account_name     = optional(string, null)
=======
      resource_suffix = string
      cidr            = string
      tags            = map(string)
>>>>>>> 900395d (naming)
    }
  ))
  description = "(Required) List of spoke configurations"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

<<<<<<< HEAD
<<<<<<< HEAD
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
=======
# variable "client_secret" {
#   type        = string
#   description = "(Required) The client secret for the service principal"
# }
#
# variable "databricks_app_object_id" {
#   type        = string
#   description = "(Required) The object ID of the AzureDatabricks App Registration"
# }
>>>>>>> 6df143a (deployed without UC)

=======
>>>>>>> 8d44021 (serverless and classic compute working)
variable "databricks_metastore_id" {
  type        = string
  default     = ""
  description = "Required if is_unity_catalog_enabled = false"
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure Subscription ID to deploy into"
}
