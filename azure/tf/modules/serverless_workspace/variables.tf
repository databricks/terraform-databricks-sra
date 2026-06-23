variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group to deploy the workspace to"
}

variable "location" {
  type        = string
  description = "(Required) The location for the workspace deployment"
}

variable "resource_suffix" {
  type        = string
  description = "(Required) Naming resource_suffix for resources"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "name_overrides" {
  type        = map(string)
  description = "(Optional) Override names for resources. Keys should match naming module outputs (e.g., 'databricks_workspace', 'private_endpoint')."
  nullable    = false
  default     = {}
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "(Required) Subnet ID where the webauth private endpoint will be created"
}

variable "dns_zone_ids" {
  type = object({
    backend = string
    dfs     = string
    blob    = string
  })
  description = "Private DNS zone IDs. Only backend is used by this module; dfs and blob are passed through as outputs for downstream consumers (e.g., hub_catalog)."
}

variable "provisioner_principal_id" {
  type        = string
  description = "Principal ID of the user/SP running this terraform; granted Contributor on the workspace"
}

variable "metastore_id" {
  type        = string
  description = "(Required) The ID of the metastore to associate with the Databricks workspace"
}

variable "ncc_id" {
  type        = string
  description = "ID of the NCC to bind to this workspace (serverless egress)"
}

variable "network_policy_id" {
  type        = string
  description = "ID of the account network policy to assign to this workspace"
}

variable "is_kms_enabled" {
  type        = bool
  description = "(Optional) Enable customer-managed key encryption for the managed services key. Managed disk CMK is not applicable to a serverless-only workspace."
  default     = false
}

variable "managed_services_key_id" {
  type        = string
  description = "(Optional) The key for managed services encryption. Required when is_kms_enabled is true."
  default     = null
}

variable "is_frontend_private_link_enabled" {
  type        = bool
  description = "(Optional) When true, disables public network access to the workspace (frontend private link only)."
  default     = false
}

variable "enhanced_security_compliance" {
  description = "(Optional) Enhanced security compliance configuration."
  type = object({
    automatic_cluster_update_enabled      = optional(bool, null)
    compliance_security_profile_enabled   = optional(bool, null)
    compliance_security_profile_standards = optional(list(string), null)
    enhanced_security_monitoring_enabled  = optional(bool, null)
  })
  nullable = false
  default  = {}
}