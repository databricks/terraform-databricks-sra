# data "databricks_user" "me" {
#   user_name = "nathan.knox@databricks.com"
# }
# resource "databricks_permission_assignment" "add_me" {
#   principal_id = data.databricks_user.me.principal_id
#   permissions  = ["ADMIN"]
# }
