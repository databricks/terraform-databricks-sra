
# data "google_client_config" "current" {
# }



resource "databricks_user" "me" {
 depends_on = [databricks_mws_workspaces.this]


 provider  = databricks.workspace
 user_name = data.google_client_openid_userinfo.me.email
#  user_name = "aleksander.callebat@databricks.com"
}


resource "databricks_group_member" "allow_me_to_login" {
 depends_on = [databricks_mws_workspaces.this]

 provider  = databricks.workspace
 group_id  = data.databricks_group.admins.id
 member_id = databricks_user.me.id
}

