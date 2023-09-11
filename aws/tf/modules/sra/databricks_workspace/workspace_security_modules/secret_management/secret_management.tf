// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret

resource "databricks_secret_scope" "app" {
  name = "application-secret-scope"
}

resource "databricks_secret" "example_app_secret" {
  key          = "example_api_secret"
  string_value = "value that should be hidden from Terraform!"
  scope        = databricks_secret_scope.app.id
}