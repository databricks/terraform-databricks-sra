variable "aws_account_id" {
  type = string
}

variable "cmk_admin_arn" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "databricks_gov_shard" {
  type = string
}

variable "databricks_prod_aws_account_id" {
  type = map(string)
}

variable "resource_prefix" {
  type = string
}

variable "uc_catalog_name" {
  type = string
}

variable "uc_master_role_id" {
  type = map(string)
}

variable "user_workspace_catalog_admin" {
  type = string
}

variable "workspace_id" {
  type = string
}