# variable "databricks_connection_profile" {
#   description = "The name of the Databricks authentication configuration profile to use."
#   type        = string
#   default     = "terraform databricks"
# }

# variable "service_principal_display_name" {
#   description = "The display name for the service principal."
#   type        = string
#   default = var.databricks_google_service_account
# }

# variable "service_principal_access_token_lifetime" {
#   description = "The lifetime of the service principal's access token, in seconds."
#   type        = number
#   default     = 3600
# }


# resource "databricks_service_principal" "sp" {
#   provider     = databricks
#   display_name = var.service_principal_display_name
# }

# # Uncomment the following "databricks_permissions" resource
# # if you want to enable the service principal to use
# # personal access tokens.
# #
# # Warning: uncommenting the following "databricks_permissions" resource
# # causes users who previously had either CAN_USE or CAN_MANAGE permission
# # to have their access to token-based authentication revoked.
# # Their active tokens are also immediately deleted (revoked).
# #
# # Alternatively, you can enable this later through the Databricks user interface.
# #
# resource "databricks_permissions" "token_usage" {
#   authorization    = "tokens"
#   access_control {
#     service_principal_name = databricks_service_principal.sp.application_id
#     permission_level       = "CAN_USE"
#   }
# }
# #
# # Uncomment the following "databricks_obo_token" resource and
# # "service_principal_access_token" output if you want to generate
# # a personal access token for service principal and then see the
# # generated personal access token.
# #
# # If you uncomment the following "databricks_obo_token" resource and
# # "service_principal_access_token" output, you must also
# # uncomment the preceding "databricks_permissions" resource.
# #
# # Alternatively, you can generate a personal access token later through the
# # Databricks user interface.
# #
# # resource "databricks_obo_token" "this" {
# #   depends_on       = [databricks_permissions.token_usage]
# #   application_id   = databricks_service_principal.sp.application_id
# #   comment          = "Personal access token on behalf of ${databricks_service_principal.sp.display_name}"
# #   lifetime_seconds = var.service_principal_access_token_lifetime
# # }

# output "service_principal_name" {
#   value = databricks_service_principal.sp.display_name
# }

# output "service_principal_id" {
#   value = databricks_service_principal.sp.application_id
# }

# # Uncomment the following "service_principal_access_token" output if
# # you want to see the generated personal access token for the service principal.
# #
# # If you uncomment the following "service_principal_access_token" output, you must
# # also uncomment the preceding "service_principal_access_token" resource and
# # "databricks_obo_token" resource.
# #
# # output "service_principal_access_token" {
# #   value     = databricks_obo_token.this.token_value
# #   sensitive = true
# # }