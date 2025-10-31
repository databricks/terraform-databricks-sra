variable "location" {
  type        = string
  description = "(Required) The location for the spoke deployment"
}

variable "vnet_cidr" {
  # Note: following chart assumes a Vnet between /16 and /24, inclusive

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
    condition     = tonumber(split("/", var.vnet_cidr)[1]) > 15 && tonumber(split("/", var.vnet_cidr)[1]) < 25
    error_message = "CIDR block must be between /16 and /24, inclusive"
  }
}

variable "route_table_id" {
  type        = string
  description = "(Optional) The ID of the route table to associate with the Databricks subnets. Required if creating network peering with hub."
  default     = null
}

variable "ipgroup_id" {
  type        = string
  description = "(Optional) The ID of the IP Group used for firewall egress rules. Required if creating network peering with hub."
  default     = null
}

variable "hub_vnet_name" {
  type        = string
  description = "(Optional) The name of the hub VNet to peer. Required if creating network peering with hub."
  default     = null
}

variable "hub_resource_group_name" {
  type        = string
  description = "(Optional) The name of the hub Resource Group to peer. Required if creating network peering with hub."
  default     = null
}

variable "hub_vnet_id" {
  type        = string
  description = "(Optional) The ID of the hub VNet to peer. Required if creating network peering with hub."
  default     = null
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

