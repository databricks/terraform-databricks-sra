# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/account_network_policy
# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_network_option

# NOTE: If this resource fails, verify that network_policy_id is no more than 32 characters.

resource "databricks_account_network_policy" "restrictive_network_policy" {
  account_id        = var.databricks_account_id
  network_policy_id = "${var.resource_prefix}-np" # Must not be more than 32 characters.

  egress = {
    network_access = {
      restriction_mode = "RESTRICTED_ACCESS"
      policy_enforcement = {
        enforcement_mode = "ENFORCED"
      }
      allowed_storage_destinations = [
        {
          bucket_name              = var.storage_buckets[0]
          region                   = var.region
          storage_destination_type = "AWS_S3"
        },
        {
          bucket_name              = var.storage_buckets[1]
          region                   = var.region
          storage_destination_type = "AWS_S3"
        }
      ]
    }
  }
}

resource "databricks_workspace_network_option" "workspace_assignement" {
  workspace_id      = var.workspace_id
  network_policy_id = databricks_account_network_policy.restrictive_network_policy.network_policy_id
}