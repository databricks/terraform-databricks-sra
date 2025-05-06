variable "alert_emails" {
  type        = list(string)
  description = "List of emails to notify when alerts are fired"
}

variable "warehouse_id" {
  type        = string
  default     = ""
  description = "Optional Warehouse ID to run queries on. If not provided, new SQL Warehouse is created"
}