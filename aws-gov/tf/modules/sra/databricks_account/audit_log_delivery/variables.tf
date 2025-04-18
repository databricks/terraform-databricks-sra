<<<<<<< HEAD
variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
}

=======
>>>>>>> fc4eee5 ([aws-gov] fix(aws-gov) update naming convention of modules, update test, add required terraform provider)
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
  type = string
}

variable "log_delivery_role_name" {
  description = "Govcloud Log Delivery Role Name."
  type = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type = string
}