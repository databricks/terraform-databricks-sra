# ----------------------------------------------------------------------------
# Storage Account variables
# ----------------------------------------------------------------------------
variable "storage_account_name" {
  type        = string
  description = "(Optional) Name of the storage account created, if not provided - a random name will be generated"
  default     = null
}

variable "storage_container_name" {
  type        = string
  description = "(Optional) Name of the storage container to create"
  default     = "unitycatalog"
}

variable "storage_account_replication_type" {
  type        = string
  description = "(Optional) Replication type for the storage account"
  default     = "GRS"
}

# ----------------------------------------------------------------------------
# Azure variables
# ----------------------------------------------------------------------------
variable "resource_suffix" {
  type        = string
  description = "(Required) Naming resource_suffix for resources"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group containing the ADB workspace"
}

variable "location" {
  type        = string
  description = "(Required) The location for the spoke deployment"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "subnet_id" {
  type        = string
  description = "(Required) ID of the subnet to place private endpoints in"
}

variable "dns_zone_ids" {
  type        = map(string)
  description = "(Required) IDs of the private DNS zones to place private endpoint records in"
}

# ----------------------------------------------------------------------------
# Databricks variables
# ----------------------------------------------------------------------------
variable "metastore_id" {
  type        = string
  description = "(Required) The ID of the metastore to associate with the Databricks workspace"
}

variable "catalog_name" {
  type        = string
  description = "(Required) Name of the catalog to create"
}

variable "force_destroy" {
  type        = bool
  description = "(Optional) Run a force destroy on the catalog if it is not empty. ONLY WORKS IF SET WHEN CATALOG IS CREATED"
  default     = false
}

variable "ncc_id" {
  type        = string
  description = "(Required) NCC ID for the workspace"
}

variable "catalog_isolation_mode" {
  type        = string
  description = "(Optional) Isolation mode for catalog. Must be one of: ISOLATED, OPEN"
  default     = "ISOLATED"
}

variable "ncc_name" {
  type        = string
  description = "Name of the NCC to use for this workspace"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID"
}

variable "is_default_namespace" {
  type        = bool
  description = "If true, sets this catalog as the default namespace for the workspace"
  default     = false
}
