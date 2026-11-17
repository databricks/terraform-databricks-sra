
locals {
  # Account admin / workspace owner. Prefer the explicit variable; fall back to
  # the current gcloud identity (which can be null under some ADC setups — hence
  # the variable).
  admin_user = var.admin_user != "" ? var.admin_user : data.google_client_openid_userinfo.me.email
}

# Random suffix so the (otherwise fixed) PSC endpoint names are unique per
# deployment — avoids collisions when deploying more than once in the same
# project/region.
resource "random_string" "psc" {
  length  = 5
  special = false
  upper   = false
}

module "service_account" {
  source = "../../modules/service_account/"

  project       = var.google_project
  sa_name       = var.sa_name
  delegate_from = var.delegate_from
  # Authentication uses impersonation (see impersonate_service_account in the
  # workspace module's google provider), so no long-lived key file is created.
  # delegate_from must include the identity running Terraform so it can mint
  # tokens for this SA (roles/iam.serviceAccountTokenCreator).
  create_service_account_key = false
}

module "make_sa_dbx_admin" {
  source = "../../modules/make_sa_dbx_admin/"

  databricks_account_id      = var.databricks_account_id
  new_admin_account          = module.service_account.workspace_creator_email
  dbx_existing_admin_account = local.admin_user
  databricks_cli_profile     = var.databricks_cli_profile
}

module "customer_managed_vpc" {
  source = "../../modules/workspace_deployment/"

  google_project        = var.google_project
  google_region         = var.google_region
  databricks_account_id = var.databricks_account_id
  # Consume the SA email via make_sa_dbx_admin's admin_service_account output so
  # this module waits until the SA has account_admin before authenticating AS
  # that SA to create the workspace. (The module declares its own providers, so
  # it cannot take a depends_on argument.)
  databricks_google_service_account = module.make_sa_dbx_admin.admin_service_account
  workspace_name                    = var.workspace_name
  regional_metastore_id             = var.regional_metastore_id

  # Grant the account admin / current identity workspace admin.
  resource_owner = local.admin_user

  # Networking — module creates VPC, subnet, PSC endpoints, firewalls
  use_existing_vpc    = false
  use_existing_pas    = false
  use_existing_PSC_EP = false
  use_psc             = true
  harden_network      = true

  # PSC service attachments and endpoint names
  workspace_service_attachment = var.workspace_service_attachment
  relay_service_attachment     = var.relay_service_attachment
  workspace_pe                 = "sra-ws-pe-${random_string.psc.result}"
  workspace_pe_ip_name         = "sra-ws-pe-ip-${random_string.psc.result}"
  relay_pe                     = "sra-relay-pe-${random_string.psc.result}"
  relay_pe_ip_name             = "sra-relay-pe-ip-${random_string.psc.result}"

  # CMEK — module creates KMS keyring + key and registers with Databricks
  use_cmek          = true
  use_existing_cmek = false
  keyring_name      = var.keyring_name
  key_name          = var.key_name

  # DNS — create a private zone for PSC resolution
  create_dns_zone = true
}
