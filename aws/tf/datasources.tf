data "aws_availability_zones" "available" {
  count = local.is_serverless ? 0 : 1
  state = "available"
}

# Account-level disable_legacy_features setting. Read before applying workspace-level legacy settings, since a
# workspace created while this is enabled has those settings locked and they can no longer be deleted.
data "databricks_account_setting_v2" "disable_legacy_features" {
  provider = databricks.mws
  name     = "disable_legacy_features"
}

# Map of every workspace name to ID in the account. Used to tell whether this deployment's workspace already exists.
data "databricks_mws_workspaces" "all" {
  provider = databricks.mws
}
