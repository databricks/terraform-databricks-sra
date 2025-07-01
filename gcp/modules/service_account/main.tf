


resource "google_service_account" "workspace_creator" {
  account_id   = "${var.sa_name}"
  display_name = "Service Account for Databricks Provisioning"
}

data "google_iam_policy" "this" {
  binding {
    role = "roles/iam.serviceAccountTokenCreator"
    members = var.delegate_from
  }
}

resource "google_service_account_iam_policy" "impersonate_workspace_creator" {
  depends_on = [google_service_account.workspace_creator]
  service_account_id = google_service_account.workspace_creator.name
  policy_data        = data.google_iam_policy.this.policy_data
}

resource "google_project_iam_custom_role" "workspace_creator" {
  role_id = "databricks_workspace_creator"
  title   = "Databricks Workspace Creator"
  permissions = [
    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.get",
    "iam.roles.update",
    "iam.serviceAccounts.create", # can be skipped if databricks-compute service account is pre-created
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    # "iam.serviceAccounts.getOpenIdToken",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "serviceusage.services.enable",
    "compute.networks.get",
    "compute.networks.updatePolicy", # can be skipped if the firewall is already pre-configured
    "compute.projects.get",
    "compute.subnetworks.get",
    "compute.subnetworks.getIamPolicy",
    "compute.subnetworks.setIamPolicy",
    "compute.forwardingRules.get",
    "compute.forwardingRules.list",
    "compute.firewalls.get",
    "compute.firewalls.create",
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",

    # ADDITIONAL AD HOC
    "compute.addresses.get",
    "compute.firewalls.update"


  ]
}

data "google_client_config" "current" {}

resource "google_project_iam_member" "workspace_creator_can_create_workspaces" {
  project = var.project
  role    = google_project_iam_custom_role.workspace_creator.id
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
}


# IF WORKSPACE CREATOR NEEDS TO CREATE THE VPC AND ENDPOINTS, THE FOLLOWING ARE NEEDED 
resource "google_project_iam_member" "workspace_creator_can_manage_VPC" {
  count = var.workspace_creator_creates_psc ? 1 : 0
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
  project = var.project
}

# IF WORKSPACE CREATOR NEEDS TO CREATE THE CMEK, THE FOLLOWING ARE NEEDED
resource "google_project_iam_member" "workspace_creator_is_kms_admin" {
  count = var.workspace_creator_creates_cmek ? 1 : 0
  role    = "roles/cloudkms.admin"
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
  project = var.project
}

