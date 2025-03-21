variable "is_kms_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable KMS (Azure Key Vault) encryption for resources"
  default     = true
}

variable "is_frontend_private_link_enabled" {
  type        = bool
  description = "(Optional - default to false) Enable frontend Private Link for Databricks workspace. When true, disables public network access."
  default     = false
}

<<<<<<< HEAD:azure/tf/modules/spoke/variables.tf
<<<<<<< HEAD:azure/tf/modules/spoke/variables.tf
=======
>>>>>>> 721eaf9 (fix linting):azure/tf/modules/azure_spoke/variables.tf
# Resource placeholder that checks to see if private_dbfs should be created
variable "boolean_create_private_dbfs" {
  description = "Whether to enable Private DBFS, all Private DBFS resources will depend on Workspace"
  type        = bool
  default     = true
}

<<<<<<< HEAD:azure/tf/modules/spoke/variables.tf
=======
variable "is_kms_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable KMS (Azure Key Vault) encryption for resources"
  default     = true
}

variable "is_frontend_private_link_enabled" {
  type        = bool
  description = "(Optional - default to false) Enable frontend Private Link for Databricks workspace. When true, disables public network access."
  default     = false
}

>>>>>>> 31c6a21 (make kms and fe privatelink optional):azure/tf/modules/azure_spoke/variables.tf
=======
>>>>>>> 721eaf9 (fix linting):azure/tf/modules/azure_spoke/variables.tf
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

variable "key_vault_id" {
  type        = string
  description = "(Required) ID of the Azure Key Vault containing the keys for CMK"

}
variable "route_table_id" {
  type        = string
  description = "(Required) The ID of the route table to associate with the Databricks subnets"
}

variable "metastore_id" {
  type        = string
  description = "(Required) The ID of the metastore to associate with the Databricks workspace"
}

variable "ipgroup_id" {
  type        = string
  description = "(Required) The ID of the IP Group used for firewall egress rules"
}

variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name of the hub VNet to peer"
}

variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name of the hub Resource Group to peer"
}

variable "hub_vnet_id" {
  type        = string
  description = "(Required) The ID of the hub VNet to peer"
}

variable "managed_disk_key_id" {
  type        = string
  description = "(Required) The key for managed disk encryption"
}

variable "managed_services_key_id" {
  type        = string
  description = "(Required) The key for the managed services encryption"
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
<<<<<<< HEAD
<<<<<<< HEAD:azure/tf/modules/spoke/variables.tf
=======

variable "is_unity_catalog_enabled" {
  type        = bool
  description = "(Optional - default to true) Enable creation of new UC"
  default     = true
}

variable "storage_account_name" {
  type        = string
  description = "(Optional) Name of the storage account created, if not provided - a random name will be generated"
  default     = null
}
<<<<<<< HEAD

variable "client_config" {
  description = "(Required) output of data block `azurerm_client_config current`"
}

variable "databricks_app_reg" {
  description = "(Required) Result of data block data.azuread_application_published_app_ids.well_known.result['AzureDataBricks']"
}
>>>>>>> 721eaf9 (fix linting):azure/tf/modules/azure_spoke/variables.tf
=======
>>>>>>> 795c8e1 (chore: Remove unused variables)
=======
>>>>>>> 791c76c (feat(azure): Remove for_each spoke creation)
