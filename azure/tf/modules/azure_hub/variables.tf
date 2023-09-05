variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name for the hub Resource Group"
}

variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name for the hub Virtual Network"
}

variable "hub_vnet_cidr" {

  type        = string
  description = "(Required) The CIDR block for the hub Virtual Network"
  validation {
    condition     = tonumber(split("/", var.hub_vnet_cidr)[1]) < 24
    error_message = "CIDR block must be at least as large as /23"
  }
}

variable "public_repos" {
  type        = list(string)
  description = "(Required) List of public repository IP addresses to allow access to."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}
