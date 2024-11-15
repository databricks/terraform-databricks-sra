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
variable "google_pe_subnet_secondary_ip_range" {
  default = "192.168.10.0/24"
}

variable "nodes_ip_cidr_range"{
  default = "10.0.0.0/16"
}

variable "pod_ip_cidr_range"{
  default = "10.1.0.0/16"
}

variable "service_ip_cidr_range"{
  default = "10.2.0.0/20"
}

variable "mws_workspace_gke_master_ip_range" {
  default = "10.3.0.0/28"
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
variable "existing_pod_range_name"{
  default = ""
}
variable "existing_service_range_name"{
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
  default = "tf-demo-test"
}



/*
Databricks PSC service attachments
https://docs.gcp.databricks.com/resources/supported-regions.html#psc
*/

variable "relay_service_attachment" {}
variable "workspace_service_attachment" {}

terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = ">=1.51.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">=5.43.1"

    }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
  impersonate_service_account = var.databricks_google_service_account
  # zone    = var.google_zone
}

// initialize provider in "accounts" mode to provision new workspace
provider "databricks" {
  alias                  = "accounts"
  host                   = var.account_console_url
  google_service_account = var.databricks_google_service_account
  account_id             = var.databricks_account_id
}



data "google_client_openid_userinfo" "me" {
}

data "google_client_config" "current" {
}

resource "random_string" "suffix" {
  special = false
  upper   = false
  length  = 6
}

provider "databricks" {
 alias                  = "workspace"
 host                   = databricks_mws_workspaces.this.workspace_url
 google_service_account = var.databricks_google_service_account
}


data "databricks_group" "admins" {
 depends_on   = [databricks_mws_workspaces.this]
 provider     = databricks.workspace
 display_name = "admins"
}


resource "databricks_user" "me" {
 depends_on = [databricks_mws_workspaces.this]


 provider  = databricks.workspace
#  user_name = data.google_client_openid_userinfo.me.email
 user_name = "aleksander.callebat@databricks.com"
}


resource "databricks_group_member" "allow_me_to_login" {
 depends_on = [databricks_mws_workspaces.this]

 provider  = databricks.workspace
 group_id  = data.databricks_group.admins.id
 member_id = databricks_user.me.id
}


