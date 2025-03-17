# Define the variable "location" with type string and a description
variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "is_kms_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable KMS (Azure Key Vault) encryption for resources"
  default     = true
}

variable "is_firewall_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable Firewall for resources"
  default     = true
}

variable "is_unity_catalog_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable creation of new UC"
  default     = true
}

# Define the variable "hub_vnet_cidr" with type string and a description
variable "hub_vnet_cidr" {

  type        = string
  description = "(Required) The CIDR block for the hub Virtual Network"

  # Add validation for the CIDR block
  validation {
    condition     = tonumber(split("/", var.hub_vnet_cidr)[1]) < 24
    error_message = "CIDR block must be at least as large as /23"
  }
}

variable "subnet_map" {
  type        = map(string)
  description = "(Required) Map of subnet names to CIDR blocks"
}

# Define the variable "public_repos" with type list of strings and a description
variable "public_repos" {
  type        = list(string)
  description = "(Required) List of public repository IP addresses to allow access to."
}

# Define the variable "tags" with type map of strings and a description
variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "firewall_sku" {
  type        = string
  description = "(Optional) SKU tier of the Firewall. Possible values are Premium, Standard and Basic"
  default     = "Standard"
}

variable "resource_suffix" {
  type        = string
  description = "(Optional) Naming resource_suffix for resources"
  default     = "hub"
}

variable "client_config" {
  type        = any
  description = "(Required) Result of data block `azurerm_client_config current`"
}

variable "databricks_app_reg" {
  type        = any
  description = "(Required) Result of data block data.azuread_application_published_app_ids.well_known.result['AzureDataBricks']"
}
