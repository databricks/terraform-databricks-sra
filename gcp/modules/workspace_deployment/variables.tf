variable "databricks_account_id" {}
variable "databricks_google_service_account" {}
variable "google_project" {}
variable "google_region" {}
# variable "google_zone" {}

variable "workspace_pe" {}
variable "relay_pe" {}


variable "account_console_url" {}

# primary subnet providing ip addresses to PSC endpoints
variable "google_pe_subnet" {}

# Private ip address assigned to PSC endpoints
variable "relay_pe_ip_name" {}
variable "workspace_pe_ip_name" {}

# For the value of the regional Hive Metastore IP, refer to the Databricks documentation
# Here - https://docs.gcp.databricks.com/en/resources/ip-domain-region.html
variable "hive_metastore_ip" {}

variable "use_existing_cmek" {}
variable "key_name" {}
variable "keyring_name" {}


variable "google_pe_subnet_ip_cidr_range" {
  default = "10.3.0.0/24"
}
# variable "google_pe_subnet_secondary_ip_range" {
#   default = "192.168.10.0/24"
# }

variable "nodes_ip_cidr_range"{
  default = "10.0.0.0/16"
}


variable "use_existing_vpc" {
  default = false
}
variable "existing_vpc_name" {
  default = ""
}
variable "existing_subnet_name" {
  default = ""
}

variable "use_existing_PSC_EP" {
  default = false
}


variable "harden_network" {
  # Flag to enable Firewall setup by the current module
  default = true
}


//Users can connect to workspace only thes list of IP's
variable "ip_addresses" {
  type = list(string)
}

variable "cmek_resource_id" {
  default = ""
}
variable "use_existing_pas" {}
variable "existing_pas_id" {
  default = ""
}
variable "workspace_name" {
  default = "sra-deployed-ws"
}



/*
Databricks PSC service attachments
https://docs.gcp.databricks.com/resources/supported-regions.html#psc
*/

variable "relay_service_attachment" {}
variable "workspace_service_attachment" {}

resource "random_string" "suffix" {
  special = false
  upper   = false
  length  = 6
}
