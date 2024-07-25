variable "databricks_account_id" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "read_only_data_bucket" {
  type = string
}

variable "read_only_external_location_admin" {
  type = string
}

variable "databricks_gov_shard" {
  type = string
}

variable "databricks_prod_aws_account_id" {
  type = map(string)
}

variable "uc_master_role_id" {
  type = map(string)
}
