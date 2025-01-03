<<<<<<< HEAD
variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "databricks_gov_shard" {
  description = "Databricks Govcloud Shard (civilian or dod)."
  type        = string
}

variable "databricks_prod_aws_account_id" {
  description = "Databricks Govcloud Prod AWS Account ID."
  type        = map(string)
}

variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "root_s3_bucket" {
  description = "S3 root bucket name for the workspace."
  type        = string
}

variable "workspace_id" {
  description = "workspace ID of deployed workspace."
  type        = string
=======
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
>>>>>>> c1185b0 (aws gov simplicity update)
}