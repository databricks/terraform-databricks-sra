# ---------------
# Mock providers
# ---------------
mock_provider "aws" {
  # This is used because the mocked data is a random string instead of JSON, causing downstream dependencies to fail.
  # This block overrides the "json" output of ALL aws_iam_policy_document data blocks to use a JSON encoded string.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"some_fake\":\"json\"}"
    }
  }
  # This is used to return valid zone names for the us-west-2 zone instead of the random strings that Terraform will
  # generate for mocked tests. Not using this will cause the data block to create an empty list of strings.
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
    }
  }
}

# A mocked databricks provider is added here so that the alias requirement can be met
mock_provider "databricks" {
  alias = "mws"

  # This is used to return valid JSON for the data types of the assume role policy.
  mock_data "databricks_aws_assume_role_policy" {
    defaults = {
      json = "{\"some_fake\":\"json\"}"
    }
  }

}
# ---------------

# ---------------
# Variables
# ---------------
# Serverless-only workspace deployment: no AWS account is required, so aws_account_id is null and the
# Hybrid Compute Mode / networking variables are left at values that must be ignored by the plan.
# Note that the below values are not real values.
variables {
  # Required variables
  aws_account_id                    = null
  compute_mode                      = "SERVERLESS"
  databricks_account_id             = "12345678-90ab-cdef-1234-567890abcdef"
  region                            = "us-west-2"
  resource_prefix                   = "my-databricks-dev"
  admin_user                        = "workspace-admin@example.com"
  audit_log_delivery_exists         = false
  enable_security_analysis_tool     = false
  metastore_exists                  = false
  network_configuration             = "isolated"
  vpc_cidr_range                    = "10.0.0.0/16"
  private_subnets_cidr              = ["10.0.1.0/24", "10.0.2.0/24"]
  privatelink_subnets_cidr          = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnets_cidr               = ["10.0.5.0/24", "10.0.6.0/24"]
  firewall_subnets_cidr             = ["10.0.7.0/24", "10.0.8.0/24"]
  sg_egress_ports                   = ["443", "3306", "6666"]
  cmk_admin_arn                     = null
  deployment_name                   = "my-databricks-workspace"
  compliance_standards              = ["PCI_DSS"]
  create_service_direct_vpce        = false
  custom_vpc_id                     = null
  custom_private_subnet_ids         = null
  custom_sg_id                      = null
  custom_general_access_vpce_id     = null
  custom_scc_relay_vpce_id          = null
  custom_service_direct_vpce_id     = null
  custom_general_access_mws_vpce_id = null
  custom_scc_relay_mws_vpce_id      = null
  custom_service_direct_mws_vpce_id = null
  workspace_display_name            = null
  custom_metastore_name             = null

  # New variables for GovCloud support
  databricks_gov_shard     = null
  aws_partition            = null
  databricks_provider_host = null
}

# ---------------
# Tests
# ---------------
# Serverless-only workspaces create no AWS resources; this plan must succeed with a null aws_account_id.
run "plan_test" {
  command = plan

  assert {
    condition     = output.catalog_name == null
    error_message = "Serverless-only workspaces must not create the customer-managed workspace catalog."
  }
}

# NOTE: The rejection of compute_mode = "SERVERLESS" in GovCloud is enforced by a precondition on
# databricks_mws_workspaces inside the workspace module. terraform test expect_failures can only
# reference root-module checkable objects, so that combination cannot be asserted here.

# us-gov-east-1 is not a supported region and must be rejected by the region variable validation.
run "unsupported_region_rejected" {
  command = plan

  variables {
    region = "us-gov-east-1"
  }

  expect_failures = [
    var.region,
  ]
}
