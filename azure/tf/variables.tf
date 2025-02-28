variable "databricks_account_id" {
  type        = string
  description = "(Required) The Databricks account ID target for account-level operations"
}
variable "location" {
  type        = string
  description = "(Required) The Azure region for the hub and spoke deployment"
}

variable "hub_vnet_cidr" {
  type        = string
  description = "(Required) The CIDR block for the hub Virtual Network"
}

variable "hub_storage_account_name" {
  type        = string
  description = "(Optional) Name of the storage account created in hub (the metastore root storage account), will be generated if not provided"
  default     = null
}

variable "hub_resource_suffix" {
  type        = string
  description = "(Required) Resource suffix for naming resources in hub, 'hub' is used if not provided"
}

variable "public_repos" {
  type        = list(string)
  description = "(Optional) List of public repository IP addresses to allow access to."
  default     = ["python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org", "cran.r-project.org", "*.cran.r-project.org", "r-project.org"]
}

variable "spoke_config" {
  type = map(object(
    {
      resource_suffix = string
      cidr            = string
      tags            = map(string)
    }
  ))
  description = "(Required) List of spoke configurations"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "databricks_metastore_id" {
  type        = string
  default     = ""
  description = "Required if is_unity_catalog_enabled = false"
}

variable "subscription_id" {
  type        = string
  description = "(Required) Azure Subscription ID to deploy into"
}
