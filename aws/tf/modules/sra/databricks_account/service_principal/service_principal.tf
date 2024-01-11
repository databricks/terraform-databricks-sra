// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal

resource "databricks_service_principal" "sp" {
  display_name         = "Example Terraform Service Principal"
  allow_cluster_create = true
}

resource "databricks_mws_permission_assignment" "admin_sp" {
  workspace_id = var.created_workspace_id
  principal_id = databricks_service_principal.sp.id
  permissions  = ["ADMIN"]
}