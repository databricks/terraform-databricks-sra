# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/automatic_cluster_update_workspace_setting

resource "databricks_automatic_cluster_update_workspace_setting" "this" {
  automatic_cluster_update_workspace {
    enabled = true
  }
}