variable "region_name" {
  type = string
}

variable "root_s3_bucket" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "databricks_gov_shard" {
  type = string
}

variable "databricks_prod_aws_account_id" {
  type = map(string)
}

variable "databricks_account_id" {
  type        = string
}