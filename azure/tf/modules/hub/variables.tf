variable "location" {
  type        = string
  description = "(Required) The location for the hub deployment"
}

variable "hub_vnet_cidr" {
  type        = string
  description = "(Required) The CIDR block for the hub Virtual Network"

  validation {
    condition     = tonumber(split("/", var.hub_vnet_cidr)[1]) < 24
    error_message = "CIDR block must be at least as large as /23"
  }
}

variable "subnet_map" {
  type        = map(string)
  description = "(Required) Map of subnet names to CIDR blocks"
}

variable "public_repos" {
  type        = list(string)
  description = "(Required) List of public repository URLs to allow for spokes"
}

variable "hub_allowed_urls" {
  type        = list(string)
  description = "(Required) List of URLs to allow the hub workspace access to"
}

variable "boolean_create_private_dbfs" {
  type        = bool
  description = "(Optional) Whether to create private DBFS DNS zones"
  default     = true
}

variable "resource_suffix" {
  type        = string
  description = "(Required) Naming resource_suffix for resources"
}

# Define the variable "tags" with type map of strings and a description
variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks account ID"
}

variable "is_firewall_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable Firewall for resources"
  default     = true
}

variable "firewall_sku" {
  type        = string
  description = "(Optional) SKU tier of the Firewall. Possible values are Premium, Standard and Basic"
  default     = "Standard"
}

variable "is_kms_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable KMS (Azure Key Vault) encryption for resources"
  default     = true
}

variable "client_config" {
  type        = any
  description = "(Required) Result of data block `azurerm_client_config current`"
}

variable "is_unity_catalog_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable creation of new UC"
  default     = true
}

variable "databricks_app_reg" {
  type        = any
  description = "(Required) Result of data block data.azuread_application_published_app_ids.well_known.result['AzureDataBricks']"
}
