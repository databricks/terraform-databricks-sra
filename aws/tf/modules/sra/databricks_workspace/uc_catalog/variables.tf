variable "aws_account_id" {
<<<<<<< HEAD
  type        = string
  description = "ID of the AWS account."
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
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
=======
  type = string
}

variable "cmk_admin_arn" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "uc_catalog_name" {
  type = string
}

variable "user_workspace_catalog_admin" {
  type = string
}

variable "workspace_id" {
  type = string
>>>>>>> b3e4c6f (aws simplicity update)
}