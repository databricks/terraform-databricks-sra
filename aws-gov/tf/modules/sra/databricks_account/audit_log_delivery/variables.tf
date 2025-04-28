variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type = string
}

variable "databricks_gov_shard" {
  description = "Databricks Govcloud Shard (civilian or dod)."
  type = string
}

variable "databricks_prod_aws_account_id" {
  description = "Databricks Govcloud Prod AWS Account ID."
  type = map(string)
}

variable "log_delivery_role_name" {
  description = "Govcloud Log Delivery Role Name."
  type = map(string)
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type = string
}