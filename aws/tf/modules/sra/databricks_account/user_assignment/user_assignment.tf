// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal

data "databricks_user" "data_access" {
  user_name = var.data_access
}

resource "databricks_mws_permission_assignment" "admin_sp" {
  workspace_id = var.created_workspace_id
  principal_id = data.databricks_user.data_access.id
  permissions  = ["ADMIN"]
}