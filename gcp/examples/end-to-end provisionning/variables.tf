
##### GENERAL VARIABLES #####
variable "databricks_account_id" {
    # Databricks account ID (found in the account console)
} 
variable "sa_name" {
    # Google service account for Databricks
    default = "databricks-workspace-creator"
} 
variable "google_project" {
    # Name of the Google Cloud project
} 

variable "google_region" {
    # Google Cloud region
} 
variable "workspace_name" { 
    # Name you want to give to the Databricks workspace you are creating
    default = "sra-deployed-ws"
}

variable "delegate_from" {
    # List of users or service accounts to delegate permissions from
    type    = list(string)
    default = []
}

variable "relay_service_attachment" {
    # Relay service attachment. regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
    default = "projects/prod-gcp-europe-west1/regions/europe-west1/serviceAttachments/ngrok-psc-endpoint"
} 
variable "workspace_service_attachment" { 
    # Workspace service attachment. Regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
    default = "projects/general-prod-europewest1-01/regions/europe-west1/serviceAttachments/plproxy-psc-endpoint-all-ports"
}


variable "regional_metastore_id" {
    # ID of the regional Hive Metastore
    default = "regional-metastore"
}

variable "provision_regional_metastore"{
    default = false
}