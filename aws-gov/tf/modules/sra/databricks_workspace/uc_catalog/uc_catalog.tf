resource "null_resource" "previous" {}

// Wait to prevent race condition between IAM role and external location validation
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "60s"
}

locals {
  uc_iam_role        = "${var.resource_prefix}-catalog-${var.workspace_id}"
  uc_catalog_name_us = replace(var.uc_catalog_name, "-", "_")
}

// Unity Catalog KMS
resource "aws_kms_key" "catalog_storage" {
  description = "KMS key for Databricks catalog storage ${var.workspace_id}"
  policy = jsonencode({
    Version : "2012-10-17",
    "Id" : "key-policy-catalog-storage-${var.workspace_id}",
    Statement : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [var.cmk_admin_arn]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow IAM Role to use the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws-us-gov:iam::${var.aws_account_id}:role/${local.uc_iam_role}"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = {
    Name    = "${var.resource_prefix}-catalog-storage-${var.workspace_id}-key"
    Project = var.resource_prefix
  }
}

resource "aws_kms_alias" "catalog_storage_key_alias" {
  name          = "alias/${var.resource_prefix}-catalog-storage-${var.workspace_id}-key"
  target_key_id = aws_kms_key.catalog_storage.id
}

// Storage Credential (created before role): https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog#configure-external-locations-and-credentials
resource "databricks_storage_credential" "workspace_catalog_storage_credential" {
  name = "${var.uc_catalog_name}-storage-credential"
  aws_iam_role {
    role_arn = "arn:aws-us-gov:iam::${var.aws_account_id}:role/${local.uc_iam_role}"
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
}

// Unity Catalog Trust Policy - Data Source
data "aws_iam_policy_document" "passrole_for_unity_catalog_catalog" {
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
      values   = ["arn:aws-us-gov:iam::${var.aws_account_id}:role/${local.uc_iam_role}"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Unity Catalog Role
resource "aws_iam_role" "unity_catalog" {
  name               = local.uc_iam_role
  assume_role_policy = data.aws_iam_policy_document.passrole_for_unity_catalog_catalog.json
  tags = {
    Name    = local.uc_iam_role
    Project = var.resource_prefix
  }
}

// Unity Catalog IAM Policy
data "aws_iam_policy_document" "unity_catalog_iam_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws-us-gov:s3:::${var.uc_catalog_name}/*",
      "arn:aws-us-gov:s3:::${var.uc_catalog_name}"
    ]

    effect = "Allow"
  }

  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws-us-gov:iam::${var.aws_account_id}:role/${local.uc_iam_role}"]
    effect    = "Allow"
  }
}

// Unity Catalog Policy
resource "aws_iam_role_policy" "unity_catalog" {
  name   = "${var.resource_prefix}-catalog-policy-${var.workspace_id}"
  role   = aws_iam_role.unity_catalog.id
  policy = data.aws_iam_policy_document.unity_catalog_iam_policy.json
}

// Unity Catalog S3
resource "aws_s3_bucket" "unity_catalog_bucket" {
  bucket        = var.uc_catalog_name
  force_destroy = true
  tags = {
    Name    = var.uc_catalog_name
    Project = var.resource_prefix
  }
}

resource "aws_s3_bucket_versioning" "unity_catalog_versioning" {
  bucket = aws_s3_bucket.unity_catalog_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "unity_catalog" {
  bucket = aws_s3_bucket.unity_catalog_bucket.bucket
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.catalog_storage.arn
    }
  }
  depends_on = [aws_kms_alias.catalog_storage_key_alias]
}

resource "aws_s3_bucket_public_access_block" "unity_catalog" {
  bucket                  = aws_s3_bucket.unity_catalog_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.unity_catalog_bucket]
}

// External Location
resource "databricks_external_location" "workspace_catalog_external_location" {
  name            = "${var.uc_catalog_name}-external-location"
  url             = "s3://${var.uc_catalog_name}/"
  credential_name = databricks_storage_credential.workspace_catalog_storage_credential.id
  comment         = "External location for catalog ${var.uc_catalog_name}"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  depends_on     = [aws_iam_role_policy.unity_catalog, time_sleep.wait_60_seconds]
}

// Workspace Catalog
resource "databricks_catalog" "workspace_catalog" {
  name           = local.uc_catalog_name_us
  comment        = "This catalog is for workspace - ${var.workspace_id}"
  isolation_mode = "ISOLATED"
  storage_root   = "s3://${var.uc_catalog_name}/"
  properties = {
    purpose = "Catalog for workspace - ${var.workspace_id}"
  }
  depends_on = [databricks_external_location.workspace_catalog_external_location]
}

// Set Workspace Catalog as Default
resource "databricks_default_namespace_setting" "this" {
  namespace {
    value = local.uc_catalog_name_us
  }
}

// Grant Admin Catalog Perms
resource "databricks_grant" "workspace_catalog" {
  catalog = databricks_catalog.workspace_catalog.name

  principal  = var.user_workspace_catalog_admin
  privileges = ["ALL_PRIVILEGES"]
}