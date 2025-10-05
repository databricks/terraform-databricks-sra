
variable "project" {
  type    = string
  default = "<my-project-id>"
}

variable "use_existing_pas" {
  description = "Use existing private access service"
  type        = bool
}
variable "existing_pas_id" {}

variable "use_psc" {
  description = "Use existing private access service"
  type        = bool
}

variable "use_existing_psc_eps" {
  description = "Use existing private access service"
  type        = bool
}

variable "use_existing_databricks_vpc_eps" {
  description = "Use existing databricks vpc endpoints"
  type        = bool
}

variable "existing_databricks_vpc_ep_workspace" {}
variable "existing_databricks_vpc_ep_relay" {}

variable "use_existing_vpc" {
  description = "Use existing vpc"
  type        = bool
}
variable "harden_network" {}

variable "use_existing_cmek" {
  description = "Use existing cmek"
  type        = bool
}

variable "databricks_google_service_account" {}

variable "google_region" {}
variable "google_project" {}

variable "existing_vpc_name" {}
variable "existing_subnet_name" {}

variable "databricks_account_id" {}
variable "key_name" {}
variable "keyring_name" {}
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

variable "workspace_name" {
  type        = string
  default     = "my-databricks-workspace"
  description = "The name of the Databricks workspace to create"
}