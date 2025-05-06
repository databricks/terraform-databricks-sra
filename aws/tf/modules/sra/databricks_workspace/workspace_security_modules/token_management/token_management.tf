// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/token

resource "databricks_token" "pat" {
  comment = "Terraform Provisioning"
  // 30 day token
  // lifetime_seconds = 2592000
  // since we only use this for provisioning new workspaces, we don't typically need this,
  // however, once expired it is reported as drift, so we're going to set it to the max
  // lifetime
}