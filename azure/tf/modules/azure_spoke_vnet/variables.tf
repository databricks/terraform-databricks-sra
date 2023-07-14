variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name of the existing hub Virtual Network"
}

variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name of the existing Resource Group containing the hub Virtual Network"
}

variable "firewall_private_ip" {
  type        = string
  description = "(Required) The hub firewall's private IP address"
}

variable "spoke_resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group to create"
}

variable "project_name" {
  type        = string
  description = "(Required) The name of the project associated with the infrastructure to be managed by Terraform"
}

variable "spoke_vnet_address_space" {
  type        = string
  description = "(Required) The address space for the spoke Virtual Network"
}

variable "privatelink_subnet_address_prefixes" {
  type        = list(string)
  description = "(Required) The address prefix(es) for the PrivateLink subnet"
}

variable "tags" {
  type        = map(string)
  description = "(Required) Map of tags to attach to resources"
}
