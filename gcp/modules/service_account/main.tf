resource "google_service_account" "workspace_creator" {
  account_id   = var.sa_name
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
    # SECURITY NOTE: project-level setIamPolicy is powerful (it can grant any
    # principal any role on the project) and is required by Databricks workspace
    # provisioning. Mitigate the privilege-escalation surface by restricting who
    # can impersonate this SA (var.delegate_from) and by keeping
    # create_service_account_key = false (no long-lived key).
    "resourcemanager.projects.setIamPolicy",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "serviceusage.services.enable",
    "compute.networks.get",
    "compute.networks.updatePolicy",
    "compute.networks.use",
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
    "cloudkms.cryptoKeyVersions.list",
    "compute.subnetworks.delete",
    "compute.networks.delete",
    "cloudkms.cryptoKeyVersions.destroy",
    "cloudkms.cryptoKeys.update",
    "compute.routers.create",
    "compute.routers.get",
    "compute.routers.update",
    "compute.routers.delete",

    # ---------------------------------------------------------------------------
    # PSC + DNS permissions (least-privilege). The documented workspace-creator
    # role only needs compute.forwardingRules.get/list because Databricks' flow
    # assumes PSC endpoints are pre-created separately. This SRA creates them with
    # the same SA, so it also needs the resource-lifecycle permissions below.
    # Permission names taken from roles/compute.networkAdmin and roles/dns.admin.
    # ---------------------------------------------------------------------------

    # PSC internal IP addresses
    "compute.addresses.create",
    "compute.addresses.createInternal",
    "compute.addresses.delete",
    "compute.addresses.deleteInternal",
    "compute.addresses.get",
    "compute.addresses.list",
    "compute.addresses.setLabels",
    "compute.addresses.use",
    "compute.addresses.useInternal",

    # PSC consumer forwarding rules (pscCreate/pscDelete are PSC-specific)
    "compute.forwardingRules.create",
    "compute.forwardingRules.delete",
    "compute.forwardingRules.pscCreate",
    "compute.forwardingRules.pscDelete",
    "compute.forwardingRules.setLabels",

    # Subnet use + operation polling for the regional PSC resources
    "compute.subnetworks.use",
    "compute.regionOperations.get",
    "compute.globalOperations.get",

    # Service Directory: PSC forwarding rules auto-register a service here
    "servicedirectory.namespaces.create",
    "servicedirectory.namespaces.get",
    "servicedirectory.namespaces.delete",
    "servicedirectory.services.create",
    "servicedirectory.services.get",
    "servicedirectory.services.delete",

    # Private DNS zone + records (create_dns_zone=true).
    # dns.networks.bindPrivateDNSZone is REQUIRED to bind a private zone to the VPC.
    "dns.managedZones.create",
    "dns.managedZones.get",
    "dns.managedZones.list",
    "dns.managedZones.update",
    "dns.managedZones.delete",
    "dns.networks.bindPrivateDNSZone",
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    "dns.resourceRecordSets.delete",
    "dns.projects.get",

  ]

}

# ASSIGNS THE (SINGLE, LEAST-PRIVILEGE) WORKSPACE CREATOR ROLE TO THE SERVICE ACCOUNT
resource "google_project_iam_member" "workspace_creator_can_create_workspaces" {
  project = var.project
  role    = google_project_iam_custom_role.workspace_creator.id
  member  = "serviceAccount:${google_service_account.workspace_creator.email}"
}

# Allow the delegated principals to impersonate the service account.
#
# Token Creator (not just Service Account User) is required for the Google
# provider's `impersonate_service_account` flow that the workspace_deployment
# module relies on. Iterating with for_each over a set both:
#   (a) avoids an index-out-of-range error when delegate_from is empty, and
#   (b) grants every delegate, not just the first list element.
resource "google_service_account_iam_member" "impersonation" {
  for_each           = toset(var.delegate_from)
  service_account_id = google_service_account.workspace_creator.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}

