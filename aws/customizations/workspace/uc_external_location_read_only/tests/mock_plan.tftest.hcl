mock_provider "aws" {}

mock_provider "databricks" {
  # The mocked assume role policy must be valid JSON for the IAM role trust policy.
  mock_data "databricks_aws_unity_catalog_assume_role_policy" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

mock_provider "time" {}

variables {
  aws_account_id                    = "123456789012"
  databricks_account_id             = "12345678-90ab-cdef-1234-567890abcdef"
  read_only_data_bucket             = "example-read-only-bucket"
  read_only_external_location_admin = "data-admins@example.com"
  resource_prefix                   = "sra-test"
}

# Plans a read-only, workspace-isolated external location over the bucket, backed by an isolated storage credential
# whose IAM role can only read that bucket.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = databricks_external_location.data_example.read_only == true && databricks_external_location.data_example.url == "s3://example-read-only-bucket/"
    error_message = "The external location must be read-only and point at the configured bucket."
  }

  assert {
    condition     = databricks_external_location.data_example.isolation_mode == "ISOLATION_MODE_ISOLATED" && databricks_storage_credential.external.isolation_mode == "ISOLATION_MODE_ISOLATED"
    error_message = "The external location and storage credential must be isolated to the workspace."
  }

  assert {
    condition     = databricks_storage_credential.external.aws_iam_role[0].role_arn == "arn:aws:iam::123456789012:role/sra-test-storage-credential-example"
    error_message = "The storage credential must use the customization's IAM role."
  }

  assert {
    condition = alltrue([
      for action in flatten([for s in jsondecode(aws_iam_role_policy.storage_credential_policy.policy).Statement : s.Action]) :
      contains(["s3:GetBucketLocation", "s3:GetLifecycleConfiguration", "s3:GetObject", "s3:ListBucket", "sts:AssumeRole"], action)
    ])
    error_message = "The storage credential role may only read the bucket (no write or delete actions)."
  }
}
