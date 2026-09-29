variable "databricks_account_id" {}
variable "new_admin_account" {}
variable "dbx_existing_admin_account" {
  description = "Existing Databricks SA or user. Allows either a user, e.g. \"name@example.com\" or a serviceAccount, e.g. \"sa1@project.iam.gserviceaccount.com\""
  default     = ""
}

variable "databricks_cli_profile" {
  type        = string
  default     = ""
  description = <<-EOT
    Optional Databricks CLI config profile (created via `databricks auth login`)
    used to authenticate the EXISTING account admin when that admin is a human
    user (not a service account). This is block-scoped to this module's provider,
    so it does not collide with other databricks providers in the same
    configuration that authenticate via google service-account impersonation.
    Takes precedence over dbx_existing_admin_account impersonation.
  EOT
}
