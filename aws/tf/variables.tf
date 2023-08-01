variable "client_id" {
  type = string
  sensitive = true
}

variable "client_secret" {
  type = string
  sensitive = true
}

variable "databricks_account_id" {
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