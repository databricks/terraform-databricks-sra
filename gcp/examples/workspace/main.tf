
module "customer_managed_vpc" {
  source                      = "../../modules/customer_managed_vpc/"
  google_project = var.google_project
  google_region = var.google_region
  initial_databricks_worskpace_user_email=var.initial_databricks_worskpace_user_email
  databricks_account_id = var.databricks_account_id
  google_zone = var.google_zone
  databricks_google_service_account = var.databricks_google_service_account
  backend_rest_psce = var.backend_rest_psce
  relay_psce = var.relay_psce
  workspace_pe = var.workspace_pe
 relay_pe =  var.relay_pe
  google_pe_subnet = var.google_pe_subnet
  relay_pe_ip_name = var.relay_pe_ip_name
  workspace_pe_ip_name = var.workspace_pe_ip_name
  relay_service_attachment = var.relay_service_attachment
  workspace_service_attachment = var.workspace_service_attachment
}
