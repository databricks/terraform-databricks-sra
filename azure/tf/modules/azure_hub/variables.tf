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
  description = "(Optional - default to false) Enable Firewall for resources"
  default     = true
}

variable "is_test_vm_enabled" {
  type        = bool
  description = "(Optional - default to false) Enable the bastion VM"
  default     = true
}


# Define the variable "hub_resource_group_name" with type string and a description
variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name for the hub Resource Group"
}

# Define the variable "hub_vnet_name" with type string and a description
variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name for the hub Virtual Network"
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

variable "client_secret" {
  type        = string
  description = "(Required) The client secret for the service principal"
}

variable "application_id" {
  type        = string
  description = "(Required) The unique identifier for the application for the service principal"
}

variable "firewall_sku" {
  type        = string
  description = "SKU tier of the Firewall. Possible values are Premium, Standard and Basic"
  default     = "Standard"
}

variable "test_vm_password" {
  type        = string
  description = "(Required) Password for the test VM"
}
