#Prefix to identify the metastore
variable "resource_prefix" {
  type = string
}

/*
Databricks workspace url which will be used for authentication by Terraform
Terraform needs one Worspace which will be used as entry point for all Databricks related operations
*/
variable "databricks_workspace_url" {}

#list of worspaces to be attached to the created metastore
variable "databricks_workspace_ids" {
  type    = list(string)
  default = []
}

#Location for the root storage bucket for unity metastore
variable "location" {}

#id of google project Ref: https://docs.gcp.databricks.com/getting-started/index.html#requirements
variable "project" {
  type    = string
  default = "<my-project-id>"
}

variable "databricks_google_service_account" {}
variable "account_console_url" {}
variable "databricks_account_id" {}
variable "databricks_workspace_ids_for_existing_metastore" {}

variable "existing_metastore_id" {}
variable "data_access" {
  type = string
}

