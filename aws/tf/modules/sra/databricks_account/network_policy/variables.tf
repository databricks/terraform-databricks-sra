variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "storage_buckets" {
  description = "List of storage buckets."
  type        = list(string)
}

variable "workspace_id" {
  description = "Workspace ID."
  type        = string
}