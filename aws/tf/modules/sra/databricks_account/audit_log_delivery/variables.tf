<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 0ef66cd ([AWS, AWS-GOV] Added Boolean for Audit Log Delivery)
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
=======
variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
<<<<<<< HEAD
  type = string
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
=======
  type        = string
>>>>>>> ecbeb76 (adding required provider versions)
}