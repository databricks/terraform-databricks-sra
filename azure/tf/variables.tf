variable "application_id" {
	type = string
	description = "(Required) Application ID in Hub unitycatalog.tf"
}
variable "databricks_account_id" {
  type        = string
  description = "(Required) The Databricks account ID target for account-level operations"
}
variable "location" {
  type        = string
  description = "(Required) The location for the hub and spoke deployment"
}

variable "hub_vnet_cidr" {
  type        = string
  description = "(Required) The CIDR block for the hub Virtual Network"
}

<<<<<<< Updated upstream
variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name for the hub Resource Group"
}

variable "hub_vnet_name" {
=======
variable "hub_resource_suffix" {
>>>>>>> Stashed changes
  type        = string
  description = "(Required) The name for the hub Virtual Network"
}

variable "public_repos" {
  type        = list(string)
  description = "(Optional) List of public repository IP addresses to allow access to."
  default     = ["python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org", "cran.r-project.org", "*.cran.r-project.org", "r-project.org"]
}

variable "spoke_config" {
  type = list(object(
    {
<<<<<<< Updated upstream
      prefix = string
      cidr   = string
      tags   = map(string)
=======
      resource_suffix          = string
      cidr                     = string
      tags                     = map(string)
      is_unity_catalog_enabled = optional(bool, true)
      storage_account_name     = optional(string, null)
>>>>>>> Stashed changes
    }
  ))
  description = "(Required) List of spoke configurations"
}

variable "test_vm_password" {
  type        = string
  description = "(Required) Password for the VM to be deployed in the hub for testing (in the absence of ExpressRoute etc.)"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "client_secret" {
  type        = string
  description = "(Required) The client secret for the service principal"
}

variable "databricks_app_object_id" {
  type        = string
  description = "(Required) The object ID of the AzureDatabricks App Registration"
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
