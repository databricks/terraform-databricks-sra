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
