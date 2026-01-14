variable "databricks_account_id" {
  type        = string
  description = "(Required) The Databricks account ID target for account-level operations"
}

variable "databricks_metastore_id" {
  type        = string
  default     = null
  description = "(Optional) Metastore ID to use for all workspaces created, required if create_hub is false"

  validation {
    condition     = var.create_hub ? true : var.databricks_metastore_id != null
    error_message = "If var.create_hub is false, you must provide databricks_metastore_id"
  }
}

variable "location" {
  type        = string
  description = "(Required) The Azure region for the hub and spoke deployment"
}

variable "create_hub" {
  type        = bool
  description = "(Optional) Whether to create the hub infrastructure. If false, hub configuration must be provided via workspace_config and spoke_config."
  default     = true
}

variable "hub_vnet_cidr" {
  type        = string
  description = "(Optional) The CIDR block for the hub Virtual Network - required if create_hub is true"
  default     = ""
  validation {
    condition     = var.create_hub ? length(var.hub_vnet_cidr) > 0 : true
    error_message = "hub_vnet_cidr is required if create_hub is true"
  }
}

variable "existing_hub_vnet" {
  type = object({
    route_table_id = string
    vnet_id        = string
  })
  description = "(Optional) Existing hub VNET details, required if create_hub is false"
  default     = null
}

variable "hub_resource_suffix" {
  type        = string
  description = "(Optional) Resource suffix for naming resources in hub - required if create_hub is true"
  default     = ""
  validation {
    condition     = var.create_hub ? length(var.hub_resource_suffix) > 0 : true
    error_message = "hub_resource_suffix is required if create_hub is true"
  }
}

# ------------------------------------------------------------------
# The below variables control what URLs workspaces can access on the internet. By default, no workspace can access the
# internet at all. Note that this means that SAT will not work by default unless the required URLs are added (see below)
#
# Common package registries: ["python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org", "cran.r-project.org", "*.cran.r-project.org", "r-project.org",]
# SAT Required URLs (classic): ["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"]
# SAT Required URLs (serverless): ["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"]
# Note: This also applies to classic compute in the WEBAUTH workspace
variable "allowed_fqdns" {
  type        = list(string)
  description = "(Optional) List of FQDNs to allow from spoke workspace."
  default     = []
  validation {
    condition     = var.sat_configuration.enabled && !var.sat_configuration.run_on_serverless ? length(setsubtract(["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"], var.allowed_fqdns)) == 0 : true
    error_message = "Since SAT is enabled and is not running on serverless, you must include SAT-required URLs in the allowed_fqdns variable."
  }
}

# This is for allowing the hub workspace to access a separate list of URLs from serverless (e.g. for SAT)
variable "hub_allowed_urls" {
  type        = set(string)
  description = "(Optional) List of URLs to allow serverless compute in the hub (webauth) workspace access to."
  default     = []

  validation {
    condition     = var.sat_configuration.enabled && var.sat_configuration.run_on_serverless ? length(setsubtract(["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"], var.hub_allowed_urls)) == 0 : true
    error_message = "Since SAT is enabled and running on serverless you must include SAT-required URLs in the hub_allowed_urls variable."
  }
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
}

variable "existing_cmk_ids" {
  type = object({
    key_vault_id            = string
    managed_disk_key_id     = string
    managed_services_key_id = string
  })
  description = "(Optional) Existing CMK IDs - required when create_hub is false and cmk_enabled is true"
  default = null

  validation {
    condition     = !var.create_hub && var.cmk_enabled ? var.existing_cmk_ids != null : true
    error_message = "existing_cmk_ids must be provided when create_hub is false and cmk_enabled is true"
  }
  validation {
    condition = var.create_hub || var.hub_settings == null || !var.cmk_enabled || (
      var.hub_settings.key_vault_id != null &&
      var.hub_settings.managed_disk_key_id != null &&
      var.hub_settings.managed_services_key_id != null
    )
    error_message = "When create_hub is false and cmk_enabled is true, key_vault_id, managed_disk_key_id, and managed_services_key_id must be provided in hub_settings"
    condition     = var.create_hub ? var.existing_cmk_ids == null : true
    error_message = "existing_cmk_ids must not be provided when create_hub is true"
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

variable "subscription_id" {
  type        = string
  description = "(Required) Azure Subscription ID to deploy into"
}

variable "sat_configuration" {
  type = object({
    enabled           = optional(bool, false)
    schema_name       = optional(string, "sat")
    catalog_name      = optional(string, "sat")
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
