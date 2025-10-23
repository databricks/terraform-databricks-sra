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
  default     = ["python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org", "cran.r-project.org", "*.cran.r-project.org", "r-project.org", "management.azure.com", "login.microsoftonline.com"]

  validation {
    condition     = var.sat_configuration.enabled && !var.sat_configuration.run_on_serverless ? length(setsubtract(["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"], var.public_repos)) == 0 : true
    error_message = "Since SAT is enabled, you must include SAT-required URLs in the hub_allowed_urls variable."
  }
}

variable "hub_allowed_urls" {
  type        = set(string)
  description = "(Optional) List of URLs to allow the hub workspace access to."
  default     = ["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"]

  validation {
    condition     = var.sat_configuration.enabled && var.sat_configuration.run_on_serverless ? length(setsubtract(["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"], var.hub_allowed_urls)) == 0 : true
    error_message = "Since SAT is enabled, you must include SAT-required URLs in the hub_allowed_urls variable."
  }
}

variable "spoke_config" {
  type = map(object(
    {
      resource_suffix         = string
      cidr                    = string
      tags                    = map(string)
      storage_account_name    = optional(string, null)
      route_table_id          = optional(string, null)
      ipgroup_id              = optional(string, null)
      hub_vnet_name           = optional(string, null)
      hub_resource_group_name = optional(string, null)
      hub_vnet_id             = optional(string, null)
    }
  ))
  description = "(Required) List of spoke configurations. When create_hub is false and spoke_network is used, hub-related fields (route_table_id, ipgroup_id, hub_vnet_name, hub_resource_group_name, hub_vnet_id) must be provided."
}

variable "workspace_config" {
  type = map(object(
    {
      spoke_name = optional(string, null)
      network_configuration = optional(object({
        virtual_network_name                                 = string
        private_subnet_name                                  = string
        public_subnet_name                                   = string
        private_subnet_network_security_group_association_id = string
        public_subnet_network_security_group_association_id  = string
        private_endpoint_subnet_name                         = string
      }), null)
      resource_group_name     = optional(string, null)
      resource_suffix         = optional(string, null)
      tags                    = optional(map(string), null)
      dns_zone_ids            = optional(map(string), null)
      ncc_id                  = optional(string, null)
      ncc_name                = optional(string, null)
      key_vault_id            = optional(string, null)
      managed_disk_key_id     = optional(string, null)
      managed_services_key_id = optional(string, null)
      network_policy_id       = optional(string, null)
      metastore_id            = optional(string, null)
    }
  ))
  description = "(Required) List of workspace configurations. When create_hub is false, hub-related fields (ncc_id, ncc_name, key_vault_id, managed_disk_key_id, managed_services_key_id, network_policy_id, metastore_id) must be provided."
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
    run_on_serverless = optional(bool, false)
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

variable "create_hub" {
  type        = bool
  description = "(Optional) Whether to create the hub infrastructure. If false, hub configuration must be provided via workspace_config and spoke_config."
  default     = true
}
