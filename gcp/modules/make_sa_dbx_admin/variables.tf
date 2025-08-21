variable "databricks_account_id" {}
variable "new_admin_account" {}
variable "dbx_existing_admin_account" {
    description = "Existing Databricks SA or user. Allows either a user, e.g. \"name@example.com\" or a serviceAccount, e.g. \"sa1@project.iam.gserviceaccount.com\""
    default     = ""
}
