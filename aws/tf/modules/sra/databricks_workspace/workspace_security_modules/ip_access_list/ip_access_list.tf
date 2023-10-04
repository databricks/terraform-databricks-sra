// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/ip_access_list

resource "databricks_workspace_conf" "this" {
  custom_config = {
    "enableIpAccessLists" = true
  }
}

resource "databricks_ip_access_list" "allowed-list" {
  label     = "allow_in"
  list_type = "ALLOW"
  ip_addresses = var.ip_addresses
  depends_on = [databricks_workspace_conf.this]
}