variable "resource_prefix" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "databricks_gov_shard" {
  type = string
}

variable "log_delivery_role_name" {
  type = map(string)
}

variable "databricks_prod_aws_account_id" {
  type = map(string)
}