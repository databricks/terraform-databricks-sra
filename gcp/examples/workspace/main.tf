
module "customer_managed_vpc" {
  source                      = "../../modules/workspace_deployment/"
  google_project = var.google_project
  google_region = var.google_region
  databricks_account_id = var.databricks_account_id
  databricks_google_service_account = var.databricks_google_service_account
  use_existing_pas = var.use_existing_pas

  workspace_pe = var.workspace_pe
 relay_pe =  var.relay_pe
  google_pe_subnet = var.google_pe_subnet 
  relay_pe_ip_name = var.relay_pe_ip_name
  workspace_pe_ip_name = var.workspace_pe_ip_name
  relay_service_attachment = var.relay_service_attachment
  workspace_service_attachment = var.workspace_service_attachment
  ip_addresses=var.ip_addresses
  account_console_url = var.account_console_url
  key_name = var.key_name
  keyring_name = var.keyring_name
  use_existing_cmek = var.use_existing_cmek
  cmek_resource_id = var.cmek_resource_id
  hive_metastore_ip = var.hive_metastore_ip
}
