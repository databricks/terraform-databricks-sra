// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/token

resource "databricks_token" "pat" {
  comment = "Terraform Provisioning"
  // 30 day token
  lifetime_seconds = 2592000
  lifecycle {
    ignore_changes = all
  }
}