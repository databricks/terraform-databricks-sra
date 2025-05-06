resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

// Storage Credential Trust Policy
data "databricks_aws_unity_catalog_assume_role_policy" "external_location_example" {
  aws_account_id = var.aws_account_id
  role_name      = "${var.resource_prefix}-storage-credential-example"
  external_id    = var.databricks_account_id
}

// Storage Credential Role
resource "aws_iam_role" "storage_credential_role" {
  name               = "${var.resource_prefix}-storage-credential-example"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.external_location_example.json
  tags = {
    Name    = "${var.resource_prefix}-storage-credential-example"
    Project = var.resource_prefix
  }
}

// Storage Credential Policy
resource "aws_iam_role_policy" "storage_credential_policy" {
  name = "${var.resource_prefix}-storage-credential-policy-example"
  role = aws_iam_role.storage_credential_role.id
  policy = jsonencode({ Version : "2012-10-17",
    Statement : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetLifecycleConfiguration",
        ],
        "Resource" : [
          "arn:aws:s3:::${var.read_only_data_bucket}/*",
          "arn:aws:s3:::${var.read_only_data_bucket}"
        ],
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          "arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential-example"
        ],
        "Effect" : "Allow"
      }
    ]
    }
  )
}

// Storage Credential
resource "databricks_storage_credential" "external" {
  name = aws_iam_role.storage_credential_role.name
  aws_iam_role {
    role_arn = aws_iam_role.storage_credential_role.arn
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  depends_on     = [aws_iam_role.storage_credential_role, time_sleep.wait_30_seconds]
}

// External Location
resource "databricks_external_location" "data_example" {
  name            = "external-location-example"
  url             = "s3://${var.read_only_data_bucket}/"
  credential_name = databricks_storage_credential.external.id
  read_only       = true
  comment         = "Read only external location for ${var.read_only_data_bucket}"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
}

// External Location Grant
resource "databricks_grants" "data_example" {
  external_location = databricks_external_location.data_example.id
  grant {
    principal  = var.read_only_external_location_admin
    privileges = ["ALL_PRIVILEGES"]
  }
}