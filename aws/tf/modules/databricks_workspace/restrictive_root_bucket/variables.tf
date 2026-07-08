variable "aws_partition" {
  type        = string
  description = "AWS partition to use for ARNs and policies"
  default     = "aws"
}

variable "databricks_account_id" {
  type        = string
  description = "ID of the Databricks account."
}

variable "databricks_aws_account_id" {
  type        = string
  description = "AWS account ID of the Databricks control plane for the target shard (commercial or GovCloud)."
}

variable "region_name" {
  type        = string
  description = "Name of the AWS region."
}

variable "root_s3_bucket" {
  type        = string
  description = "S3 root bucket name for the workspace."
}

variable "workspace_id" {
  type        = string
  description = "workspace ID of deployed workspace."
}