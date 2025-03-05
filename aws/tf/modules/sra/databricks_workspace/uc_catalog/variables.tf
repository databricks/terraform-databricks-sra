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
=======
  type        = string
  description = "ID of the AWS account."
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
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
<<<<<<< HEAD
  type = string
>>>>>>> b3e4c6f (aws simplicity update)
=======
  description = "workspace ID of deployed workspace."
  type        = string
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
}