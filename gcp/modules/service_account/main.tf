variable "prefix" {}

variable "project" {
  type    = string
}

variable "workspace_creator_creates_cmek"{
  type = bool
  default = false
}

variable "workspace_creator_creates_psc" {
  type = bool
  default = false
}

variable "workspace_create_modifies_compute_SA" {
  type = bool
  default = false
}

provider "google" {
  project = var.project
}


# The user principal can be allowed to impersonate a service account using this parameter.
#  Set to a user principal who should impersonate a service account for purposes of 
#  account infrastructure provisioning and workspace setup.
variable "delegate_from" {
  description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
  type        = list(string)
}

resource "google_service_account" "workspace_creator" {
  account_id   = "${var.prefix}-workspace-creator"
  display_name = "Service Account for Databricks Provisioning"
}

output "service_account" {
  value       = google_service_account.workspace_creator.email
  description = "Add this email as a user in the Databricks account console"
}

data "google_iam_policy" "this" {
  binding {
    role = "roles/iam.serviceAccountTokenCreator"
    members = var.delegate_from
  }
}

resource "google_service_account_iam_policy" "impersonate_workspace_creator" {
  service_account_id = google_service_account.workspace_creator.name
  policy_data        = data.google_iam_policy.this.policy_data
}

resource "google_project_iam_custom_role" "workspace_creator" {
  role_id = "${var.prefix}_workspace_creator"
  title   = "Databricks Workspace Creator"
  permissions = [
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.get",
    "iam.roles.update",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "serviceusage.services.enable",
    "compute.networks.get",
    "compute.projects.get",
    "compute.subnetworks.get",
    "iam.serviceAccounts.getOpenIdToken",

  ]
}

data "google_client_config" "current" {}

output "current_project" {
  value = data.google_client_config.current.project
}

output "role_id" {
  value = google_project_iam_custom_role.workspace_creator.role_id
}

output "custom_role_url" {
  value = "https://console.cloud.google.com/iam-admin/roles/details/projects%3C${data.google_client_config.current.project}%3Croles%3C${google_project_iam_custom_role.workspace_creator.role_id}"
}

resource "google_project_iam_member" "workspace_creator_can_create_workspaces" {
  project = var.project
  role    = google_project_iam_custom_role.workspace_creator.id
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
}


# GRANTS THE WORKSPACE CREATOR THE CAPACITY TO USE PRE-CREATED PSC ENDPOINTS
resource "google_project_iam_member" "workspace_creator_can_usePSC" {
  count = var.workspace_creator_creates_psc ? 0 : 1
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
  project = var.project
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

resource "google_project_iam_member" "workspace_creator_is_kms_viewer" {
  count = var.workspace_creator_creates_cmek ? 0 : 1
  role    = "roles/cloudkms.viewer"
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
  project = var.project
}

# IF WORKSPACE CREATOR NEEDS TO BRING A DIFFERENT ROLE TO MANAGE THE NODES
resource "google_project_iam_member" "workspace_creator_is_owner" {
  count = var.workspace_create_modifies_compute_SA ? 1 : 0
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
  project = var.project

}
