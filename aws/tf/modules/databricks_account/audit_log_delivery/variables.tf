variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "aws_assume_partition" {
  description = "AWS partition to use for assume role policies"
  type        = string
  default     = "aws"
}