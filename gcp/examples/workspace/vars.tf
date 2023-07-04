variable "prefix" {}

variable "project" {
  type    = string
  default = "<my-project-id>"
}

variable "delegate_from" {
  description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
  type        = list(string)
}

variable "databricks_google_service_account" {}

variable "google_region" {}
variable "google_project" {}

variable "databricks_account_id" {}
variable "google_zone" {}
variable "backend_rest_psce" {}
variable "relay_psce" {}

variable "workspace_pe" {}
variable "relay_pe" {}

# primary subnet providing ip addresses to PSC endpoints
variable "google_pe_subnet" {}

# Private ip address assigned to PSC endpoints
variable "relay_pe_ip_name" {}
variable "workspace_pe_ip_name" {}

variable "relay_service_attachment" {}
variable "workspace_service_attachment" {}