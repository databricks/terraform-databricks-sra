data "google_client_config" "current" {}

# Get current user for impersonation setup
data "google_client_openid_userinfo" "me" {}

# data "google_iam_policy" "this" {
#   binding {
#     role = "roles/iam.serviceAccountTokenCreator"
#     members = concat(var.delegate_from, [
#       "user:${data.google_client_openid_userinfo.me.email}"
#     ])
#   }
# }

resource "random_string" "prefix" {
    length  = 8
    upper   = false
    special = false
}