variable "databricks_account_username" {
  type = string
  sensitive = true
}

variable "databricks_account_password" {
  type = string
  sensitive = true
}

variable "databricks_account_id" {
  type = string
  sensitive = true
}

variable "aws_access_key" {
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

variable "aws_account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_owner" {
  type = string
}

variable "resource_prefix" {
  type = string
}