
module "service_account" {
  source = "../../modules/service_account/"

  project                    = var.google_project
  sa_name                    = var.sa_name
  create_service_account_key = true
  delegate_from              = var.delegate_from
}

module "make_sa_dbx_admin" {
  source = "../../modules/make_sa_dbx_admin/"

  databricks_account_id      = var.databricks_account_id
  new_admin_account          = module.service_account.workspace_creator_email
  dbx_existing_admin_account = data.google_client_openid_userinfo.me.email
}

module "customer_managed_vpc" {
  source = "../../modules/workspace_deployment/"

  google_project                        = var.google_project
  google_region                         = var.google_region
  databricks_account_id                 = var.databricks_account_id
  databricks_google_service_account     = module.service_account.workspace_creator_email
  workspace_name                        = var.workspace_name
  databricks_google_service_account_key = module.service_account.workspace_creator_key
  regional_metastore_id                 = var.regional_metastore_id
  can_create_workspaces                 = module.service_account.workspace_creator_role_applied
  admin_user_email                      = module.make_sa_dbx_admin.original_admin_account

  # Networking — module creates VPC, subnet, PSC endpoints, firewalls
  use_existing_vpc    = false
  use_existing_pas    = false
  use_existing_PSC_EP = false
  use_psc             = true
  harden_network      = true

  # PSC service attachments and endpoint names
  workspace_service_attachment = var.workspace_service_attachment
  relay_service_attachment     = var.relay_service_attachment
  workspace_pe                 = "sra-workspace-pe"
  workspace_pe_ip_name         = "sra-workspace-pe-ip"
  relay_pe                     = "sra-relay-pe"
  relay_pe_ip_name             = "sra-relay-pe-ip"

  # CMEK — module creates KMS keyring + key and registers with Databricks
  use_cmek          = true
  use_existing_cmek = false
  keyring_name      = var.keyring_name
  key_name          = var.key_name

  # DNS — create a private zone for PSC resolution
  create_dns_zone = true

  provision_regional_metastore = false
}
