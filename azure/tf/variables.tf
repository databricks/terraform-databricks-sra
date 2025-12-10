variable "databricks_account_id" {
  type        = string
  description = "(Required) The Databricks account ID target for account-level operations"
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
variable "public_repos" {
  type        = list(string)
  description = "(Optional) List of public repository IP addresses to allow access to."
  default     = []
  validation {
    condition     = var.sat_configuration.enabled && !var.sat_configuration.run_on_serverless ? length(setsubtract(["management.azure.com", "login.microsoftonline.com", "python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org"], var.public_repos)) == 0 : true
    error_message = "Since SAT is enabled and is not running on serverless, you must include SAT-required URLs in the public_repos variable."
  }
}

variable "hub_allowed_urls" {
  type        = set(string)
  description = "(Optional) List of URLs to allow the hub workspace access to."
  default     = []

  validation {
    condition     = var.sat_configuration.enabled && var.sat_configuration.run_on_serverless ? length(setsubtract(["management.azure.com", "login.microsoftonline.com", "python.org", "pypi.org", "pythonhosted.org"], var.hub_allowed_urls)) == 0 : true
    error_message = "Since SAT is enabled and running on serverless you must include SAT-required URLs in the hub_allowed_urls variable."
  }
}
# ------------------------------------------------------------------

variable "spoke_config" {
  type = map(object(
    {
      # ------------------------------------------------------------------
      # These keys are required
      resource_suffix = string
      cidr            = string
      tags            = map(string)
      # ------------------------------------------------------------------
      # These keys are required if you are bringing your own hub
      route_table_id          = optional(string, null)
      hub_vnet_name           = optional(string, null)
      hub_resource_group_name = optional(string, null)
      hub_vnet_id             = optional(string, null)
      # ------------------------------------------------------------------
      # These keys are optional
      ipgroup_id = optional(string, null)
      new_bits   = optional(number, null)
      # ------------------------------------------------------------------
    }
  ))
  description = "(Optional) List of spoke configurations. When create_hub is false, hub-related fields (route_table_id, hub_vnet_name, hub_resource_group_name, hub_vnet_id) must be provided."
  default     = {}

  validation {
    condition = var.create_hub || alltrue([
      for k, v in var.spoke_config :
      v.route_table_id != null
    ])
    error_message = "When create_hub is false, all spokes must provide route_table_id"
  }
  validation {
    condition = var.create_hub || alltrue([
      for k, v in var.spoke_config :
      v.hub_vnet_name != null
    ])
    error_message = "When create_hub is false, all spokes must provide hub_vnet_name"
  }
  validation {
    condition = var.create_hub || alltrue([
      for k, v in var.spoke_config :
      v.hub_vnet_id != null
    ])
    error_message = "When create_hub is false, all spokes must provide hub_vnet_id"
  }
  validation {
    condition = var.create_hub || alltrue([
      for k, v in var.spoke_config :
      v.route_table_id != null
    ])
    error_message = "When create_hub is false, all spokes must provide route_table_id"
  }
}

variable "workspace_config" {
  type = map(object(
    {
      spoke_name = optional(string, null)
      # ------------------------------------------------------------------
      # These keys are required if you are bringing your own spoke VNET
      network_configuration = optional(object({
        virtual_network_id                                   = string
        private_subnet_id                                    = string
        public_subnet_id                                     = string
        private_endpoint_subnet_id                           = string
        private_subnet_network_security_group_association_id = string
        public_subnet_network_security_group_association_id  = string
      }), null)
      dns_zone_ids = optional(object({
        backend = string
        dfs     = string
        blob    = string
      }), null)
      resource_group_name = optional(string, null)
      resource_suffix     = optional(string, null)
      tags                = optional(map(string), null)
      # ------------------------------------------------------------------
      # These keys are required if you are bringing your own hub
      ncc_id            = optional(string, null)
      ncc_name          = optional(string, null)
      network_policy_id = optional(string, null)
      metastore_id      = optional(string, null)

      # These keys are required if is_kms_enabled is true and you bring your own hub
      key_vault_id            = optional(string, null)
      managed_disk_key_id     = optional(string, null)
      managed_services_key_id = optional(string, null)
      # ------------------------------------------------------------------
      # The below keys are always optional
      is_kms_enabled = optional(bool, true)
      enhanced_security_compliance = optional(object({
        automatic_cluster_update_enabled      = optional(bool, null)
        compliance_security_profile_enabled   = optional(bool, null)
        compliance_security_profile_standards = optional(list(string), null)
        enhanced_security_monitoring_enabled  = optional(bool, null)
      }), null)
      name_overrides = optional(map(string), null)
      # ------------------------------------------------------------------
    }
  ))
  description = "(Required) List of workspace configurations. When create_hub is false, hub-related fields (ncc_id, ncc_name, key_vault_id, managed_disk_key_id, managed_services_key_id, network_policy_id, metastore_id) must be provided."

  # This validation checks that if the user is creating spoke networks using this configuration, that a valid spoke key is selected for every workspace
  validation {
    condition = alltrue([
      for workspace in values(var.workspace_config) :
      workspace.spoke_name == null || contains(keys(var.spoke_config), workspace.spoke_name)
    ])
    error_message = "If spoke_name is provided, it must be configured as a spoke in var.spoke_config"
  }

  # This validation checks that if a user does not create spoke networking with this configuration, that all of the required network_configuration values are provided.
  validation {
    condition = alltrue([
      for workspace in values(var.workspace_config) :
      workspace.spoke_name == null ? workspace.network_configuration != null : true
    ])
    error_message = "If spoke_name is not provided, network_configuration must be provided"
  }

  # This validation checks that if create_hub is false, then the hub-related variable values are present in all spokes.
  validation {
    condition = alltrue([
      for workspace in values(var.workspace_config) :
      var.create_hub ? true : alltrue([for config_value in [workspace.ncc_id, workspace.ncc_name, workspace.network_policy_id, workspace.metastore_id] : config_value != null])
    ])
    error_message = "If create_hub is false - ncc_id, ncc_name, network_policy_id, metastore_id must be provided"
  }
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "databricks_metastore_id" {
  type        = string
  default     = ""
  description = "(Optional) Metastore ID to use for all workspaces created, required if create_hub is false"

  validation {
    condition     = var.create_hub ? true : var.databricks_metastore_id != null
    error_message = "If var.create_hub is false, you must provide databricks_metastore_id"
  }
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
