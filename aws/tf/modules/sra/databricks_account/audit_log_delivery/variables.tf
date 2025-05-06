variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}