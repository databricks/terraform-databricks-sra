variable "is_storage_private_endpoint_enabled" {
  type        = bool
  description = "(Optional - default to false) Enable private endpoints for dbfs"
  default     = false
}

variable "location" {
  type        = string
  description = "(Required) The location for the spoke deployment"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the spoke Resource Group to create"
}

variable "vnet_cidr" {
  # Note: following chart assumes a Vnet between /16 and /24, inclusive, with only 2 subnets (ADB workers)
  # todo: size for private link subnet in spoke (for dbfs) - will need to be able to have 3 subnets.

  # | Subnet Size (CIDR) | Maximum ADB Cluster Nodes |
  # | /17	| 32763 |
  # | /18	| 16379 |
  # | /19	| 8187 |
  # | /20	| 4091 |
  # | /21	| 2043 |
  # | /22	| 1019 |
  # | /23	| 507 |
  # | /24	| 251 |
  # | /25	| 123 |
  # | /26	| 59 |

  type        = string
  description = "(Required) The CIDR block for the spoke Virtual Network"
  # default     = "10.2.1.0/24"
  validation {
    condition     = tonumber(substr(var.vnet_cidr, -2, -1)) > 15 && tonumber(substr(var.vnet_cidr, -2, -1)) < 25
    error_message = "CIDR block must be between /16 and /24, inclusive"
  }
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

variable "prefix" {
  type        = string
  description = "(Required) Naming prefix for resources"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}
