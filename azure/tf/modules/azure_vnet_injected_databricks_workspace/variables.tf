variable "workspace_name" {
  type        = string
  description = "Name of Databricks workspace"
}

variable "databricks_resource_group_name" {
  type        = string
  description = "Name of resource group into which Databricks will be deployed"
}

variable "location" {
  type        = string
  description = "Location in which Databricks will be deployed"
}

variable "vnet_id" {
  type        = string
  description = "ID of existing virtual network into which Databricks will be deployed"
}

variable "vnet_name" {
  type        = string
  description = "Name of existing virtual network into which Databricks will be deployed"
}

variable "nsg_id" {
  type        = string
  description = "ID of existing Network Security Group"
}

variable "route_table_id" {
  type        = string
  description = "ID of existing Route Table"
}

variable "private_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for private Databricks subnet"
}

variable "public_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for public Databricks subnet"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to attach to Databricks workspace"
}
