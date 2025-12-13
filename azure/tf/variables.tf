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
# ------------------------------------------------------------------
# Workspace Variables
variable "create_workspace_resource_group" {
  type        = string
  description = "(Optional) Should a resource group be created for this workspace? If false, resource_group_name must be provided."
  default     = true
}

variable "existing_resource_group_name" {
  type        = string
  description = "(Optional) Existing resource group name, if using one"
  default     = null
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
variable "resource_suffix" {
  type        = string
  description = "(Required) Suffix to use for naming Azure resources (e.g. dbx-dev, sra, etc.)"
}

variable "create_workspace_vnet" {
  type        = bool
  description = "(Optional) Whether to create SRA-managed workspace VNET. If false, workspace_vnet must be provided."
  default     = true
}

variable "workspace_vnet" {
  type = object({
    cidr     = string
    new_bits = optional(number, null)
  })
  description = "(Optional) Spoke network configuration - required when create_workspace_vnet is true."
  default     = null

  validation {
    condition     = var.create_workspace_vnet ? var.workspace_vnet != null : true
    error_message = "workspace_vnet must be provided when create_workspace_vnet is true"
  }
  validation {
    condition     = !var.create_workspace_vnet ? var.workspace_vnet == null : true
    error_message = "workspace_vnet must not be provided when create_workspace_vnet is false"
  }
}

variable "existing_workspace_vnet" {
  type = object({
    network_configuration = object({
      virtual_network_id                                   = string
      private_subnet_id                                    = string
      public_subnet_id                                     = string
      private_endpoint_subnet_id                           = string
      private_subnet_network_security_group_association_id = string
      public_subnet_network_security_group_association_id  = string
    })
    dns_zone_ids = object({
      backend = string
      dfs     = string
      blob    = string
    })
  })
  description = "(Optional) Existing network configuration - required when create_workspace_vnet is false"
  default     = null

  validation {
    condition     = !var.create_workspace_vnet ? var.existing_workspace_vnet != null : true
    error_message = "existing_workspace_vnet must be provided when create_workspace_vnet is false"
  }

  validation {
    condition     = var.create_workspace_vnet ? var.existing_workspace_vnet == null : true
    error_message = "existing_workspace_vnet should only be provided when create_workspace_vnet is false"
  }
}

variable "hub_settings" {
  type = object({
    ncc_id            = string
    ncc_name          = string
    network_policy_id = string

    key_vault_id            = optional(string, null)
    managed_disk_key_id     = optional(string, null)
    managed_services_key_id = optional(string, null)
  })
  description = "(Conditional) Hub settings - required when create_hub is false"
  default     = null

  validation {
    condition     = var.create_hub || var.hub_settings != null
    error_message = "hub_settings must be provided when create_hub is false"
  }

  validation {
    condition     = !var.create_hub || var.hub_settings == null
    error_message = "hub_settings should only be provided when create_hub is true"
  }

  validation {
    condition = var.create_hub || var.hub_settings == null || !var.cmk_enabled || (
      var.hub_settings.key_vault_id != null &&
      var.hub_settings.managed_disk_key_id != null &&
      var.hub_settings.managed_services_key_id != null
    )
    error_message = "When create_hub is false and cmk_enabled is true, key_vault_id, managed_disk_key_id, and managed_services_key_id must be provided in hub_settings"
  }
}

variable "cmk_enabled" {
  type        = bool
  description = "(Optional) Whether to enable customer-managed keys (CMK) for workspace encryption. When enabled, managed disks and services will be encrypted with customer-managed keys."
  default     = true
}

variable "workspace_security_compliance" {
  type = object({
    automatic_cluster_update_enabled      = optional(bool, null)
    compliance_security_profile_enabled   = optional(bool, null)
    compliance_security_profile_standards = optional(list(string), null)
    enhanced_security_monitoring_enabled  = optional(bool, null)
  })
  description = "(Optional) Enhanced security compliance configuration for the workspace"
  default     = null
}

variable "workspace_name_overrides" {
  type        = map(string)
  description = "(Optional) Override names for workspace resources. Keys should match naming module outputs."
  default     = {}
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
