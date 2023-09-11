// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal

data "databricks_group" "admins" {
  display_name = "admins"
}

resource "databricks_service_principal" "sp" {
  display_name         = "Example Terraform Service Principal"
  allow_cluster_create = true
}

resource "databricks_group_member" "sp-admin" {
  group_id  = data.databricks_group.admins.id
  member_id = databricks_service_principal.sp.id
}