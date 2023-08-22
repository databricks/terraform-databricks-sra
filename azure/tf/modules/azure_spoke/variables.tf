variable "is_storage_private_endpoint_enabled" {
  type        = bool
  description = "(Optional - default to false) Enable private endpoints for dbfs"
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

variable "route_table_id" {
  type        = string
  description = "(Required) The ID of the route table to associate with the Databricks subnets"
}

variable "metastore_id" {
  type        = string
  description = "(Required) The ID of the metastore to associate with the Databricks workspace"
}

variable "hub_peering_info" {
  type = object({
    rg_name   = string
    vnet_name = string
    vnet_id   = string
  })
  description = "(Required) Hub VNet information required for peering"
}

variable "naming_prefix" {
  type        = string
  description = "(Required) Naming prefix for resources"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}
