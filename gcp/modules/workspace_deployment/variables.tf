variable "databricks_account_id" {
    # Databricks account ID (found in the account console)
} 
variable "databricks_google_service_account" {
    # Google service account for Databricks
    # This service account must have the "Databricks Workspace Creatore" role or equivalent
    # and the "Databricks Account Admin" role in the Databricks account console
} 
variable "google_project" {
    # Name of the Google Cloud project
} 
variable "google_region" {
# Google Cloud project ID
} 

variable "workspace_pe" {
    # Name of the PSC endpoint (found in GCP console) used for the workspace communication
} 
variable "relay_pe" {
    # Name of the PSC endpoint (found in the GCP console) used for the relay communication
} 

variable "account_console_url" {
    default = "https://accounts.cloud.databricks.com" # Databricks account console URL
} 

# primary subnet providing ip addresses to PSC endpoints
variable "google_pe_subnet" {} # Google Cloud private endpoint subnet

# Private ip address assigned to PSC endpoints
variable "relay_pe_ip_name" {} # Relay private endpoint IP name
variable "workspace_pe_ip_name" {} # Workspace private endpoint IP name

# For the value of the regional Hive Metastore IP, refer to the Databricks documentation
# Here - https://docs.gcp.databricks.com/en/resources/ip-domain-region.html
variable "hive_metastore_ip" {} # Hive Metastore IP address

variable "use_existing_cmek" { # Flag to use an existing CMEK
    default = false
}
variable "key_name" {} # Key name for CMEK
variable "keyring_name" {} # Keyring name for CMEK

variable "google_pe_subnet_ip_cidr_range" { # CIDR range for private endpoint subnet
  default = "10.3.0.0/24"
}

variable "nodes_ip_cidr_range" { # CIDR range for nodes
  default = "10.0.0.0/16"
}

variable "use_existing_vpc" { # Flag to use an existing VPC
  default = false
}
variable "existing_vpc_name" { # Name of the existing VPC
  default = ""
}
variable "existing_subnet_name" { # Name of the existing subnet
  default = ""
}

variable "use_existing_PSC_EP" { # Flag to use an existing PSC endpoint
  default = false
}

variable "harden_network" { # Flag to enable network hardening with firewalls
  default = true
}

// Users can connect to workspace only these list of IP's
variable "ip_addresses" { # List of allowed IP addresses
  type = list(string)
}

variable "cmek_resource_id" { # Resource ID for CMEK
  default = ""
}
variable "use_existing_pas" { # Flag to use an existing private access settings
    default = false
}
variable "existing_pas_id" { # ID of the existing private access settings
  default = ""
}
variable "workspace_name" { # Name of the Databricks workspace
  default = "sra-deployed-ws"
}

/*
Databricks PSC service attachments
https://docs.gcp.databricks.com/resources/supported-regions.html#psc
*/

variable "relay_service_attachment" {} # Relay service attachment
variable "workspace_service_attachment" {} # Workspace service attachment

resource "random_string" "suffix" { # Random string generator for suffix
  special = false
  upper   = false
  length  = 6
}
