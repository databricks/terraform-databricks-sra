resource "local_file" "service_account_key" {
  count           = var.create_service_account_key ? 1 : 0
  content         = base64decode(google_service_account_key.workspace_creator_key[count.index].private_key)
  filename        = "${path.module}/workspace-creator-key.json"
  file_permission = "0600"
}

# Optional: Create service account key for authentication
resource "google_service_account_key" "workspace_creator_key" {
  count              = var.create_service_account_key ? 1 : 0
  service_account_id = google_service_account.workspace_creator.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}


resource "null_resource" "set_application_google_credential" {
  count = var.create_service_account_key ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOF
      # Set GOOGLE_APPLICATION_CREDENTIALS for current session
      export GOOGLE_APPLICATION_CREDENTIALS="${local_file.service_account_key[count.index].filename}"
      
      # Write to a source-able script for persistence
      echo "export GOOGLE_APPLICATION_CREDENTIALS='${local_file.service_account_key[count.index].filename}'" > ${path.module}/set_credentials.sh
      chmod +x ${path.module}/set_credentials.sh
      
      # Also create a .env file for easy sourcing
      echo "GOOGLE_APPLICATION_CREDENTIALS=${local_file.service_account_key[count.index].filename}" > ${path.module}/.env
      
      echo "GOOGLE_APPLICATION_CREDENTIALS has been set to: ${local_file.service_account_key[count.index].filename}"
    EOF
  }

  depends_on = [local_file.service_account_key]
}
