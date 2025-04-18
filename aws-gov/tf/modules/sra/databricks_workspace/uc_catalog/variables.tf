variable "aws_account_id" {
<<<<<<< HEAD
<<<<<<< HEAD
  type        = string
  description = "ID of the AWS account."
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
}

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

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "uc_catalog_name" {
  description = "UC catalog name isolated to the workspace."
  type        = string
}

variable "uc_master_role_id" {
  description = "Govcloud UC Master Role ID"
  type        = map(string)
}

variable "user_workspace_catalog_admin" {
  description = "Workspace catalog admin - same user as the account admin."
  type        = string
}

variable "workspace_id" {
  description = "workspace ID of deployed workspace."
  type        = string
=======
  type = string
=======
  type        = string
  description = "ID of the AWS account."
>>>>>>> fc4eee5 ([aws-gov] fix(aws-gov) update naming convention of modules, update test, add required terraform provider)
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
}

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

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "uc_catalog_name" {
  description = "UC catalog name isolated to the workspace."
  type        = string
}

variable "uc_master_role_id" {
  description = "Govcloud UC Master Role ID"
  type        = map(string)
}

variable "user_workspace_catalog_admin" {
  description = "Workspace catalog admin - same user as the account admin."
  type        = string
}

variable "workspace_id" {
<<<<<<< HEAD
  type = string
>>>>>>> c1185b0 (aws gov simplicity update)
=======
  description = "workspace ID of deployed workspace."
  type        = string
>>>>>>> fc4eee5 ([aws-gov] fix(aws-gov) update naming convention of modules, update test, add required terraform provider)
}