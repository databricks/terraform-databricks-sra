locals {
  profile_refresh_command = "databricks auth login -p ${var.auth_profile_name} --host ${var.host}"
  profile_delete_command  = "databricks auth logout -p ${var.auth_profile_name} --delete --auto-approve"
}

resource "terraform_data" "ephemeral_profile" {
  triggers_replace = [local.profile_refresh_command, local.profile_delete_command]

  provisioner "local-exec" {
    command = self.triggers_replace[0]
  }

  provisioner "local-exec" {
    when    = destroy
    command = self.triggers_replace[1]
  }
}