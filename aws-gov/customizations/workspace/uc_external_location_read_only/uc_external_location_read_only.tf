resource "null_resource" "previous" {}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "60s"
}

// Storage Credential
resource "databricks_storage_credential" "external" {
  name = aws_iam_role.storage_credential_role.name
  aws_iam_role {
    role_arn = aws_iam_role.storage_credential_role.arn
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
}

// Storage Credential Trust Policy
data "aws_iam_policy_document" "passrole_for_storage_credential" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:role/unity-catalog-prod-UCMasterRole-${var.uc_master_role_id[var.databricks_gov_shard]}"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws-us-gov:iam::${var.aws_account_id}:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws-us-gov:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Storage Credential Role
resource "aws_iam_role" "storage_credential_role" {
  name               = "${var.resource_prefix}-storage-credential-example"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_storage_credential.json
  tags = {
    Name    = "${var.resource_prefix}-storage-credential-example"
    Project = var.resource_prefix
  }
}

// Storage Credential Policy
resource "aws_iam_role_policy" "storage_credential_policy" {
  name = "${var.resource_prefix}-storage-credential-policy-example"
  role = aws_iam_role.storage_credential_role.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetLifecycleConfiguration",
        ],
        "Resource" : [
          "arn:aws-us-gov:s3:::${var.read_only_data_bucket}/*",
          "arn:aws-us-gov:s3:::${var.read_only_data_bucket}"
        ],
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          "arn:aws-us-gov:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential-example"
        ],
        "Effect" : "Allow"
      }
    ]
    }
  )
}

// External Location
resource "databricks_external_location" "data_example" {
  name            = "external-location-example"
  url             = "s3://${var.read_only_data_bucket}/"
  credential_name = databricks_storage_credential.external.id
  read_only       = true
  comment         = "Read only external location for ${var.read_only_data_bucket}"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  depends_on     = [time_sleep.wait_60_seconds]
}

// External Location Grant
resource "databricks_grants" "data_example" {
  external_location = databricks_external_location.data_example.id
  grant {
    principal  = var.read_only_external_location_admin
    privileges = ["ALL_PRIVILEGES"]
  }
}