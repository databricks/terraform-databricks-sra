variable "is_storage_private_endpoint_enabled" {
  type        = bool
  description = "(Optional - default to false) Enable private endpoint for storage account"
  default     = false
}

variable "location" {
  type        = string
  description = "(Required) The location for the spoke deployment"
}

variable "spoke_resource_group_name" {
  type        = string
  description = "(Required) The name of the spoke Resource Group to create"
}

variable "spoke_vnet_cidr" {
  type        = string
  description = "(Required) The CIDR block for the spoke Virtual Network"
  # default     = "10.2.1.0/24"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}
