variable "aws_account_id" {
  type        = string
  description = "ID of the AWS account. Not required when is_serverless is true."
  default     = null
}

variable "aws_iam_partition" {
  type        = string
  description = "AWS partition to use for IAM ARNs and policies"
  default     = "aws"
}

variable "aws_assume_partition" {
  type        = string
  description = "AWS partition to use for assume role policies"
  default     = "aws"
}

variable "unity_catalog_iam_arn" {
  type        = string
  description = "Unity Catalog IAM ARN for the master role"
  default     = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin. Not required when is_serverless is true."
  type        = string
  default     = null
}

variable "is_serverless" {
  description = "When true, the workspace catalog uses Databricks default storage and the customer-managed AWS storage (KMS, IAM, S3, storage credential, external location) is skipped."
  type        = bool
  default     = false
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "uc_catalog_name" {
  description = "UC catalog name isolated to the workspace."
  type        = string
}

variable "user_workspace_catalog_admin" {
  description = "Workspace catalog admin - same user as the account admin."
  type        = string
}

variable "workspace_id" {
  description = "workspace ID of deployed workspace."
  type        = string
}