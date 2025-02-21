data "databricks_current_user" "me" {}

locals {
  qa_data     = jsondecode(file("${path.module}/queries_and_alerts.json"))["queries_and_alerts"]
  directories = toset(compact(flatten([for k in local.qa_data : [k.parent, try(k.alert.parent, null)]])))
  queries     = toset([for k in local.qa_data : k.name])
  alerts      = toset([for k in local.qa_data : k.name if try(k.alert, null) != null])
  data_map    = { for k in local.qa_data : k.name => k }
}

resource "databricks_directory" "this" {
  for_each = local.directories
  path     = "${data.databricks_current_user.me.home}/${each.value}"
}