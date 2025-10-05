
##### GENERAL VARIABLES #####
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

## TODO : default value not a variable
variable "account_console_url" {
    default = "https://accounts.gcp.databricks.com" # Databricks account console URL
} 
variable "workspace_name" { 
    # Name you want to give to the Databricks workspace you are creating
    default = "sra-deployed-ws"
}
resource "random_string" "suffix" { 
    # Random string generator for suffix used in resource names.
    special = false
    upper   = false
    length  = 6
}

variable "databricks_google_service_account_key" {
    # Base64 encoded service account key for the Google service account
    # This is optional and can be used if you want to authenticate using a key file
    default = ""
}


##### NETWORKING VARIABLES #####
variable "use_existing_vpc" { 
    # Flag to use an existing VPC
    default = false
}
variable "existing_vpc_name" { 
    # Name of the existing VPC. Keep it empty if you want to create a new one.
    default = ""
}
variable "existing_subnet_name" { 
    # Name of the existing subnet. Keep it empty if you want to create a new one.
    default = ""
}
variable "nodes_ip_cidr_range" { 
    # CIDR range for nodes. See https://docs.databricks.com/gcp/en/admin/cloud-configurations/gcp/network-sizing for sizing details.
    # This is important as it can't be changed after the workspace is created.
    default = "10.0.0.0/16"
}
variable "use_existing_PSC_EP" { 
    # Flag to use an existing PSC endpoint
    default = false
}
variable "google_pe_subnet" {
    #Name of the subnet to be used for the PSC endpoints
    default = "databricks-pe-subnet"
} 
variable "google_pe_subnet_ip_cidr_range" { 
    # CIDR range for private endpoint subnet
    default = "10.3.0.0/24"
}
variable "workspace_pe" {
    # Name of the PSC endpoint (found in GCP console) used for the workspace communication
    default = "worskspace-pe"
}   
variable "relay_pe" {
    # Name of the PSC endpoint (found in the GCP console) used for the relay communication
    default = "relay-pe"
} 
variable "workspace_pe_ip_name" {
    # Workspace private endpoint IP name
    default = ""
} 
variable "relay_pe_ip_name" {
    # Name of the relay private endpoint IP
    default = ""
} 
variable "harden_network" { 
    # Flag to enable network hardening with firewalls rules
    default = true
}
variable "hive_metastore_ip" {
    # For the value of the regional Hive Metastore IP, refer to the Databricks documentation
    # Here - https://docs.gcp.databricks.com/en/resources/ip-domain-region.html
    default = "34.76.244.202" # Value for europe-west1 region
}

// Users can connect to workspace only these list of IP's
variable "ip_addresses" { 
    # List of allowed IP addresses
    type = list(string)
    default = ["0.0.0.0/0"] # This is a default value allowing all IPs. Change it to restrict access.
}
variable "relay_service_attachment" {
    # Relay service attachment. regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
    default = ""
} 
variable "workspace_service_attachment" { 
    # Workspace service attachment. Regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
    default = ""
}
variable "use_existing_pas" { 
    # Flag to use an existing private access settings (this will be rarely the case)
    default = false
}
variable "existing_pas_id" { 
    # ID of the existing private access settings (only needed if use_existing_pas is true)
    default = ""
}


###### CMEK VARIABLES ######
variable "use_existing_cmek" { 
    # Flag to use an existing CMEK
    default = false
}
variable "key_name" {
    # Key name for CMEK. only needed if use_existing_cmek is false
    default = "sra-key"

} 
variable "keyring_name" {
    # Keyring name for CMEK. only needed if use_existing_cmek is false
    default = "sra-keyring"
} 
variable "cmek_resource_id" { 
    # Resource ID for CMEK. only needed if use_existing_cmek is true
    default = ""
}

variable "use_psc" {
    # Flag to use Private Service Connect (PSC) for the workspace
    default = false
}

variable "use_existing_databricks_vpc_eps" {
    # Flag to use existing Databricks VPC Endpoints for PSC
    default = false
}
variable "existing_databricks_vpc_ep_workspace" {}
variable "existing_databricks_vpc_ep_relay" {}

variable "admin_user_email" {
    # Email address of the admin user to be added to the workspace
    type = string
    default = ""
    description = "Email of the user to be granted admin access to the workspace"
}

variable "can_create_workspaces" {
    # Flag to allow the service account to create workspaces
    type = bool
    default = true
    description = "Flag to timeout the creation of the workspace"
}

variable "create_admin_user" {
    # Flag to create the admin user in the workspace
    type = bool
    default = false
    description = "Flag to create the admin user in the workspace"
}

variable "regional_metastore_id" {
    # Name of the regional Hive Metastore
    default = ""
}

variable "provision_regional_metastore"{
    # Flag to provision a regional Hive Metastore
    default = false
}