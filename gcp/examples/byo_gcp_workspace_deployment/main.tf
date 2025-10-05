
module "customer_managed_vpc" {
  source                      = "../../modules/workspace_deployment/"
  google_project = var.google_project #Google Cloud project id (GCP)
  google_region = var.google_region  #Google Cloud region (GCP)
  databricks_account_id = var.databricks_account_id #Databricks account id (Databricks)
  databricks_google_service_account = var.databricks_google_service_account
  workspace_name = var.workspace_name #Name of the Databricks workspace to be created (Databricks)
  account_console_url = var.account_console_url #Databricks Account console url (Databricks)

    
  
  #IP ACCESS LIST
  ip_addresses=var.ip_addresses #Databricks Workspace IP Access List (Databricks)
 
  #VPC RESOURCES
  use_existing_vpc = var.use_existing_vpc #Flag to use existing vpc or create a new one
  existing_vpc_name = var.existing_vpc_name
  existing_subnet_name = var.existing_subnet_name

  #PSC RESOURCES
  google_pe_subnet = var.google_pe_subnet #Name of the subnet to be used for the PSC endpoints (GCP)

  use_psc = var.use_psc #Flag to enable Private Service Connect (PSC) for the workspace
  use_existing_pas = var.use_existing_pas #Flag to use existing private access settings or create a new one
  existing_pas_id = var.existing_pas_id #Required if use_existing_pas is true
  use_existing_PSC_EP = var.use_existing_psc_eps #Flag to use existing PSC endpoints or create a new ones
  use_existing_databricks_vpc_eps = var.use_existing_databricks_vpc_eps #Flag to use existing Databricks VPC Endpoints for PSC or create a new ones

  workspace_service_attachment = var.workspace_service_attachment #Workspace service attachment. Regional values - https://docs.databricks.com/gcp/en/resources/ip-domain-region#private-service-connect-psc-attachment-uris-and-project-numbers
  workspace_pe = var.workspace_pe #Name of the PSC endpoint (found in GCP console) used for the workspace communication (GCP)
  workspace_pe_ip_name = var.workspace_pe_ip_name #Workspace private endpoint IP name if not using an existing one (GCP)
  existing_databricks_vpc_ep_workspace = var.existing_databricks_vpc_ep_workspace #Required if use_existing_databricks_vpc_eps is true. 
  existing_databricks_vpc_ep_relay = var.existing_databricks_vpc_ep_relay #Required if use_existing_databricks_vpc_eps is true.

  relay_service_attachment = var.relay_service_attachment #Relay service attachment. Regional values - https://docs.databricks.com/gcp/en/resources/ip-domain-region#private-service-connect-psc-attachment-uris-and-project-numbers
  relay_pe =  var.relay_pe #Name of the PSC endpoint (found in GCP console) used for the relay communication (GCP)
  relay_pe_ip_name = var.relay_pe_ip_name #Relay private endpoint IP name if not using an existing one (GCP)
  
  #CMEK RESOURCES
  use_existing_cmek = var.use_existing_cmek #Flag to use existing Cloud KMS Key or create a new one
  key_name = var.key_name #Name of the key to be created if not using an existing one (GCP)
  keyring_name = var.keyring_name #Name of the keyring to be created if not using an existing one (GCP)
  cmek_resource_id = var.cmek_resource_id #Resource ID for the existing Cloud KMS Key (GCP)

    # Flags
  harden_network               = var.harden_network
  provision_regional_metastore  = false 
}
