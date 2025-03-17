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

<<<<<<< HEAD
<<<<<<< HEAD
=======
variable "is_test_vm_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable the bastion VM"
  default     = true
}

<<<<<<< HEAD
variable "test_vm_password" {
  type        = string
  description = "(Required) Password for the test VM"
}

>>>>>>> 60cc2bc (remove redundant module naming)
=======
>>>>>>> 6df143a (deployed without UC)
=======
>>>>>>> 795c8e1 (chore: Remove unused variables)
variable "is_unity_catalog_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable creation of new UC"
  default     = true
}

<<<<<<< HEAD
<<<<<<< HEAD
=======
# Define the variable "hub_resource_group_name" with type string and a description
variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name for the hub Resource Group"
}

<<<<<<< HEAD
# Define the variable "hub_vnet_name" with type string and a description
variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name for the hub Virtual Network"
}

>>>>>>> 60cc2bc (remove redundant module naming)
=======
>>>>>>> bba9fc9 (remove vnet naming option in the hub to standardize approach, add example tfvars)
=======
>>>>>>> ad6dd10 (outputs, naming variables)
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

<<<<<<< HEAD
<<<<<<< HEAD
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
<<<<<<< HEAD
<<<<<<< HEAD
  type        = any
=======
>>>>>>> 8d44021 (serverless and classic compute working)
=======
  type        = any
>>>>>>> 3b1a557 (chore: Add missing descriptions and types to outputs and variables)
  description = "(Required) Result of data block `azurerm_client_config current`"
}

variable "databricks_app_reg" {
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 3b1a557 (chore: Add missing descriptions and types to outputs and variables)
  type        = any
  description = "(Required) Result of data block data.azuread_application_published_app_ids.well_known.result['AzureDataBricks']"
}

variable "boolean_create_private_dbfs" {
  description = "Whether to enable Private DBFS, all Private DBFS resources will depend on Workspace"
  type        = bool
  default     = true
}

variable "is_frontend_private_link_enabled" {
  type        = bool
  description = "(Optional - default to false) Enable frontend Private Link for Databricks workspace. When true, disables public network access."
  default     = false
}
=======
variable "client_secret" {
  type        = string
  description = "(Required) The client secret for the service principal"
}

variable "application_id" {
  type        = string
  description = "(Required) The unique identifier for the application for the service principal"
}

=======
>>>>>>> 6df143a (deployed without UC)
variable "firewall_sku" {
  type        = string
  description = "(Optional) SKU tier of the Firewall. Possible values are Premium, Standard and Basic"
  default     = "Standard"
}
<<<<<<< HEAD
>>>>>>> 60cc2bc (remove redundant module naming)
=======

variable "resource_suffix" {
  type        = string
  description = "(Optional) Naming resource_suffix for resources"
  default     = "hub"
}
>>>>>>> 900395d (naming)
=======
  description = "(Required) Result of data block data.azuread_application_published_app_ids.well_known.result['AzureDataBricks']"
}
>>>>>>> 8d44021 (serverless and classic compute working)
