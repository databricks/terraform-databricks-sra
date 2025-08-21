
output "current_project" {
  value = data.google_client_config.current.project
}

output "role_id" {
  value = google_project_iam_custom_role.workspace_creator.role_id
}

output "custom_role_url" {
  value = "https://console.cloud.google.com/iam-admin/roles/details/projects%3C${data.google_client_config.current.project}%3Croles%3C${google_project_iam_custom_role.workspace_creator.role_id}"
}


output "workspace_creator_email" {
  value = google_service_account.workspace_creator.email
}

output "workspace_creator_key" {
  value     = var.create_service_account_key ? google_service_account_key.workspace_creator_key[0].private_key : null
  sensitive = true
}

output "workspace_creator_key_file_path" {
  value       = var.create_service_account_key ? "${path.module}/workspace-creator-key.json" : null
  description = "Path to the service account key file"
}

output "credentials_setup_script" {
  value       = var.create_service_account_key ? "${path.module}/set_credentials.sh" : null
  description = "Path to script that sets GOOGLE_APPLICATION_CREDENTIALS"
}


output "workspace_creator_role_applied" {
  value = google_project_iam_member.workspace_creator_can_create_workspaces.id != null
}