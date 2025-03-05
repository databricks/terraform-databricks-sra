variable "databricks_account_id" {
<<<<<<< HEAD
<<<<<<< HEAD
  type        = string
  description = "ID of the Databricks account."
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
=======
  type = string
=======
  type        = string
  description = "ID of the Databricks account."
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
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
<<<<<<< HEAD
  type = string
>>>>>>> b3e4c6f (aws simplicity update)
=======
  type        = string
  description = "workspace ID of deployed workspace."
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
}