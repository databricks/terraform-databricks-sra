variable "network_connectivity_config_id" {
  type        = string
  description = "ID of the NCC to use for this private endpoint rule"
}

variable "network_connectivity_config_name" {
  type        = string
  description = "Name of the NCC to use for this private endpoint rule. Only used in the description of the approval."
  default     = ""
}

variable "group_id" {
  type        = string
  description = "Group ID of the azure resource, e.g. blob or dfs"
}

variable "resource_id" {
  type        = string
  description = "Resource ID of the azure resource"
}

variable "data_api_type" {
  type        = string
  description = "Resource API to use with the AzAPI data source"
  default     = "Microsoft.Storage/storageAccounts@2024-01-01"
}

variable "update_api_type" {
  type        = string
  description = "Resource API to use with the AzAPI update resource"
  default     = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2024-01-01"
}
