# ----- Terraform Provider Variables ------
variable "tenant_id" {
  type = string
  description = "(Required) Tenant ID in providers.tf"
}

variable "subscription_id" {
  type = string
  description = "(Required) Subscription ID in providers.tf"
} 

variable "client_id" {
  type = string
  description = "(Required) Client ID in providers.tf"
}


# ------ Azure Databrick SRA Variables ------

variable "application_id" {
	type = string
	description = "(Required) Application ID in Hub unitycatalog.tf"
}
variable "databricks_account_id" {
  type        = string
  description = "(Required) The Databricks account ID target for account-level operations"
}
variable "location" {
  type        = string
  description = "(Required) The location for the hub and spoke deployment"
}

variable "hub_vnet_cidr" {
  type        = string
  description = "(Required) The CIDR block for the hub Virtual Network"
}

variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name for the hub Resource Group"
}

variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name for the hub Virtual Network"
}

variable "public_repos" {
  type        = list(string)
  description = "(Optional) List of public repository IP addresses to allow access to."
  default     = ["python.org", "*.python.org", "pypi.org", "*.pypi.org", "pythonhosted.org", "*.pythonhosted.org", "cran.r-project.org", "*.cran.r-project.org", "r-project.org"]
}

variable "spoke_config" {
  type = list(object(
    {
      prefix = string
      cidr   = string
      tags   = map(string)
    }
  ))
  description = "(Required) List of spoke configurations"
}

variable "test_vm_password" {
  type        = string
  description = "(Required) Password for the VM to be deployed in the hub for testing (in the absence of ExpressRoute etc.)"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}

variable "client_secret" {
  type        = string
  description = "(Required) The client secret for the service principal"
}

variable "databricks_app_object_id" {
  type        = string
  description = "(Required) The object ID of the AzureDatabricks App Registration"
}
