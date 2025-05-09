
variable "project" {
  type    = string
  default = "<my-project-id>"
}

variable "delegate_from" {
  description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
  type        = list(string)
}
variable "use_existing_pas" {
  description = "Use existing private access service"
  type        = bool
  default     = false
}
variable "databricks_google_service_account" {}

variable "google_region" {}
variable "google_project" {}

variable "databricks_account_id" {}
variable "key_name" {}
variable "keyring_name" {}
variable "use_existing_cmek" {}
variable "hive_metastore_ip" {}
variable "cmek_resource_id" {}

variable "workspace_pe" {}
variable "relay_pe" {}

# primary subnet providing ip addresses to PSC endpoints
variable "google_pe_subnet" {}

# Private ip address assigned to PSC endpoints
variable "relay_pe_ip_name" {}
variable "workspace_pe_ip_name" {}

variable "relay_service_attachment" {}
variable "workspace_service_attachment" {}

variable "account_console_url" {}
//Users can connect to workspace only thes list of IP's
variable "ip_addresses" {
  type = list(string)
}