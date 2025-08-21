resource "google_service_account" "workspace_creator" {
  account_id   = "${var.sa_name}"
  display_name = "Service Account for Databricks Provisioning"
}


resource "google_project_iam_custom_role" "workspace_creator" {
  role_id = "databricks_sra_workspace_creator_${random_string.prefix.result}"
  title   = "Databricks Workspace Creator for SRA"
  permissions = [
    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.get",
    "iam.roles.update",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "iam.serviceAccounts.getOpenIdToken",
    "iam.serviceAccounts.getAccessToken",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "serviceusage.services.enable",
    "compute.networks.get",
    "compute.networks.updatePolicy",
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

    # Optional: Allow creating extra needed resources
    "cloudkms.keyRings.create",
    "cloudkms.keyRings.get",
    "cloudkms.cryptoKeys.create",
    "cloudkms.cryptoKeys.get",
    "compute.networks.create",
    "compute.subnetworks.create",
    "compute.firewalls.update",
    "compute.firewalls.delete",
    "iam.serviceAccounts.getAccessToken",
    "cloudkms.cryptoKeyVersions.list",
    "compute.subnetworks.delete",
    "compute.networks.delete",
    "cloudkms.cryptoKeyVersions.destroy",
    "cloudkms.cryptoKeys.update",
    "compute.routers.create",
    "compute.routers.get",
    "compute.routers.update",
    "compute.routers.delete",

  ]

}

# ASSIGNGS WORKSPACE CREATOR ROLE TO THE SERVICE ACCOUNT
resource "google_project_iam_member" "workspace_creator_can_create_workspaces" {
  project = var.project
  role    = google_project_iam_custom_role.workspace_creator.id
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
}

# Allow current user to impersonate the service account
resource "google_service_account_iam_member" "impersonation" {
  service_account_id = google_service_account.workspace_creator.name
  role               = "roles/iam.serviceAccountUser"
  member             = var.delegate_from[0]
}

