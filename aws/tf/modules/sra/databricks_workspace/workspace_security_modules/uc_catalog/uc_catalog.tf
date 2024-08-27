resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "30s"
}

// Unity Catalog Trust Policy - Data Source
data "databricks_aws_unity_catalog_assume_role_policy" "unity_catalog" {
  aws_account_id = var.aws_account_id
  role_name      = "${var.resource_prefix}-catalog-${var.workspace_id}"
  external_id    = var.databricks_account_id
}

// Unity Catalog Role
resource "aws_iam_role" "unity_catalog_role" {
  name               = "${var.resource_prefix}-catalog-${var.workspace_id}"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.unity_catalog.json
  tags = {
    Name    = "${var.resource_prefix}-catalog-${var.workspace_id}"
    Project = var.resource_prefix
  }
}

// Unity Catalog Policy - Data Source
data "databricks_aws_unity_catalog_policy" "unity_catalog_iam_policy" {
  aws_account_id = var.aws_account_id
  bucket_name    = var.uc_catalog_name
  role_name      = "${var.resource_prefix}-catalog-${var.workspace_id}"
  kms_name       = aws_kms_alias.catalog_storage_key_alias.arn
}

// Unity Catalog Policy
resource "aws_iam_role_policy" "unity_catalog" {
  name   = "${var.resource_prefix}-catalog-policy-${var.workspace_id}"
  role   = aws_iam_role.unity_catalog_role.id
  policy = data.databricks_aws_unity_catalog_policy.unity_catalog_iam_policy.json
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
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-catalog-${var.workspace_id}"
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

// Storage Credential
resource "databricks_storage_credential" "workspace_catalog_storage_credential" {
  name = aws_iam_role.unity_catalog_role.name
  aws_iam_role {
    role_arn = aws_iam_role.unity_catalog_role.arn
  }
  depends_on     = [aws_iam_role.unity_catalog_role, time_sleep.wait_30_seconds]
  isolation_mode = "ISOLATION_MODE_ISOLATED"
}

// External Location
resource "databricks_external_location" "workspace_catalog_external_location" {
  name            = var.uc_catalog_name
  url             = "s3://${var.uc_catalog_name}/catalog/"
  credential_name = databricks_storage_credential.workspace_catalog_storage_credential.id
  comment         = "External location for catalog ${var.uc_catalog_name}"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
}

// Workspace Catalog
resource "databricks_catalog" "workspace_catalog" {
  name           = var.uc_catalog_name
  comment        = "This catalog is for workspace - ${var.workspace_id}"
  isolation_mode = "ISOLATED"
  storage_root   = "s3://${var.uc_catalog_name}/catalog/"
  properties = {
    purpose = "Catalog for workspace - ${var.workspace_id}"
  }
  depends_on = [databricks_external_location.workspace_catalog_external_location]
}

// Grant Admin Catalog Perms
resource "databricks_grant" "workspace_catalog" {
  catalog = databricks_catalog.workspace_catalog.name

  principal  = var.workspace_catalog_admin
  privileges = ["ALL_PRIVILEGES"]
}
