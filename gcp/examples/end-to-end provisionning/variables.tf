
##### GENERAL VARIABLES #####
variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (found in the account console)"
}

variable "sa_name" {
  type        = string
  default     = "databricks-workspace-creator"
  description = "Google service account name for Databricks provisioning"
}

variable "google_project" {
  type        = string
  description = "Google Cloud project ID"
}

variable "google_region" {
  type        = string
  description = "Google Cloud region"
}

variable "workspace_name" {
  type        = string
  default     = "sra-deployed-ws"
  description = "Name of the Databricks workspace to create"
}

variable "delegate_from" {
  type        = list(string)
  default     = []
  description = "List of users or service accounts to delegate impersonation from (e.g. [\"user:you@example.com\"])"
}

variable "admin_user" {
  type        = string
  default     = ""
  description = <<-EOT
    Email of the Databricks account admin (and workspace resource owner). Used to
    bootstrap the new provisioning SA as an account admin and to grant workspace
    admin. If left empty, it falls back to the current gcloud identity via
    data.google_client_openid_userinfo.me.email — but that can be null under some
    ADC setups (e.g. `gcloud auth application-default login` without the right
    scopes), so set this explicitly if you hit an empty/null admin.
  EOT
}

variable "databricks_cli_profile" {
  type        = string
  default     = ""
  description = <<-EOT
    Optional Databricks CLI profile (from `databricks auth login`) used to
    bootstrap account_admin when admin_user is a human user. Leave empty if the
    existing admin is a service account (it will be impersonated instead).
  EOT
}

##### PSC #####
variable "workspace_service_attachment" {
  type        = string
  description = "PSC service attachment URI for the workspace endpoint (plproxy). See https://docs.databricks.com/gcp/en/resources/ip-domain-region"
}

variable "relay_service_attachment" {
  type        = string
  description = "PSC service attachment URI for the SCC relay endpoint (ngrok). See https://docs.databricks.com/gcp/en/resources/ip-domain-region"
}

##### CMEK #####
variable "keyring_name" {
  type        = string
  default     = "databricks-keyring"
  description = "Name of the KMS keyring to create"
}

variable "key_name" {
  type        = string
  default     = "databricks-key"
  description = "Name of the KMS crypto key to create"
}

##### METASTORE #####
variable "regional_metastore_id" {
  type        = string
  default     = ""
  description = "ID of the regional Unity Catalog metastore to assign (leave empty to skip)"
}
