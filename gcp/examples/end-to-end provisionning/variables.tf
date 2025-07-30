
##### GENERAL VARIABLES #####
variable "databricks_account_id" {
    # Databricks account ID (found in the account console)
} 
variable "databricks_google_service_account" {
    # Google service account for Databricks
    # This service account must have the "Databricks Workspace Creator" role or equivalent
    # and the "Databricks Account Admin" role in the Databricks account console
} 
variable "google_project" {
    # Name of the Google Cloud project
} 
variable "google_region" {
    # Google Cloud project ID
    default = "europe-west1"
} 
variable "workspace_name" { 
    # Name you want to give to the Databricks workspace you are creating
    default = "sra-deployed-ws"
}


variable "relay_service_attachment" {
    # Relay service attachment. regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
    default = "projects/prod-gcp-europe-west1/regions/europe-west1/serviceAttachments/ngrok-psc-endpoint"
} 
variable "workspace_service_attachment" { 
    # Workspace service attachment. Regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
    default = "projects/general-prod-europewest1-01/regions/europe-west1/serviceAttachments/plproxy-psc-endpoint-all-ports"
}



