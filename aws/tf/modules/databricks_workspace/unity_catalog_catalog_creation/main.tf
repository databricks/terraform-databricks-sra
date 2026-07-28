# In SERVERLESS compute mode the customer-managed AWS storage (KMS key, IAM role/policy, S3 bucket,
# storage credential, external location) is skipped and the workspace catalog uses Databricks default
# storage. In HYBRID mode the full customer-managed catalog storage is provisioned.

resource "null_resource" "previous" {
  count = var.is_serverless ? 0 : 1
}

# Wait to prevent race condition between IAM role and external location validation
resource "time_sleep" "wait_60_seconds" {
  count           = var.is_serverless ? 0 : 1
  depends_on      = [null_resource.previous]
  create_duration = "60s"
}

locals {
  uc_iam_role        = "${var.resource_prefix}-catalog-${var.workspace_id}"
  uc_catalog_name_us = replace(var.uc_catalog_name, "-", "_")
}

# Unity Catalog KMS
resource "aws_kms_key" "catalog_storage" {
  count               = var.is_serverless ? 0 : 1
  description         = "KMS key for Databricks catalog storage ${var.workspace_id}"
  enable_key_rotation = true
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
          "AWS" : "arn:${var.aws_iam_partition}:iam::${var.aws_account_id}:role/${local.uc_iam_role}"
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
  count         = var.is_serverless ? 0 : 1
  name          = "alias/${var.resource_prefix}-catalog-storage-${var.workspace_id}-key"
  target_key_id = aws_kms_key.catalog_storage[0].id
}

# Storage Credential (created before role): https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog#configure-external-locations-and-credentials
resource "databricks_storage_credential" "workspace_catalog_storage_credential" {
  count = var.is_serverless ? 0 : 1
  name  = "${var.uc_catalog_name}-storage-credential"
  aws_iam_role {
    role_arn = "arn:${var.aws_iam_partition}:iam::${var.aws_account_id}:role/${local.uc_iam_role}"
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
}

# Unity Catalog Trust Policy - Data Source
data "databricks_aws_unity_catalog_assume_role_policy" "unity_catalog" {
  count                 = var.is_serverless ? 0 : 1
  aws_account_id        = var.aws_account_id
  aws_partition         = var.aws_assume_partition
  role_name             = local.uc_iam_role
  unity_catalog_iam_arn = var.unity_catalog_iam_arn
  external_id           = databricks_storage_credential.workspace_catalog_storage_credential[0].aws_iam_role[0].external_id
}

# Unity Catalog Policy - Data Source
data "databricks_aws_unity_catalog_policy" "unity_catalog" {
  count          = var.is_serverless ? 0 : 1
  aws_account_id = var.aws_account_id
  aws_partition  = var.aws_assume_partition
  bucket_name    = var.uc_catalog_name
  role_name      = local.uc_iam_role
  kms_name       = aws_kms_alias.catalog_storage_key_alias[0].arn
}

# Unity Catalog Policy
resource "aws_iam_policy" "unity_catalog" {
  count  = var.is_serverless ? 0 : 1
  name   = "${var.resource_prefix}-catalog-policy-${var.workspace_id}"
  policy = data.databricks_aws_unity_catalog_policy.unity_catalog[0].json
}

# Unity Catalog Role
resource "aws_iam_role" "unity_catalog" {
  count              = var.is_serverless ? 0 : 1
  name               = local.uc_iam_role
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.unity_catalog[0].json
  tags = {
    Name    = local.uc_iam_role
    Project = var.resource_prefix
  }
}

# Unity Catalog Policy Attachment
resource "aws_iam_policy_attachment" "unity_catalog_attach" {
  count      = var.is_serverless ? 0 : 1
  name       = "unity_catalog_policy_attach"
  roles      = [aws_iam_role.unity_catalog[0].name]
  policy_arn = aws_iam_policy.unity_catalog[0].arn
}

# Unity Catalog S3
resource "aws_s3_bucket" "unity_catalog_bucket" {
  count         = var.is_serverless ? 0 : 1
  bucket        = var.uc_catalog_name
  force_destroy = true
  tags = {
    Name    = var.uc_catalog_name
    Project = var.resource_prefix
  }
}

resource "aws_s3_bucket_versioning" "unity_catalog_versioning" {
  count  = var.is_serverless ? 0 : 1
  bucket = aws_s3_bucket.unity_catalog_bucket[0].id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "unity_catalog" {
  count  = var.is_serverless ? 0 : 1
  bucket = aws_s3_bucket.unity_catalog_bucket[0].bucket
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.catalog_storage[0].arn
    }
  }
  depends_on = [aws_kms_alias.catalog_storage_key_alias]
}

resource "aws_s3_bucket_public_access_block" "unity_catalog" {
  count                   = var.is_serverless ? 0 : 1
  bucket                  = aws_s3_bucket.unity_catalog_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.unity_catalog_bucket]
}

# External Location
resource "databricks_external_location" "workspace_catalog_external_location" {
  count           = var.is_serverless ? 0 : 1
  name            = "${var.uc_catalog_name}-external-location"
  url             = "s3://${var.uc_catalog_name}/"
  credential_name = databricks_storage_credential.workspace_catalog_storage_credential[0].id
  comment         = "External location for catalog ${var.uc_catalog_name}"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  depends_on      = [aws_iam_policy_attachment.unity_catalog_attach, time_sleep.wait_60_seconds]
}

# Workspace Catalog
# In SERVERLESS mode storage_root is omitted so the catalog uses Databricks default (managed) storage.
resource "databricks_catalog" "workspace_catalog" {
  name           = local.uc_catalog_name_us
  comment        = "This catalog is for workspace - ${var.workspace_id}"
  isolation_mode = "ISOLATED"
  storage_root   = var.is_serverless ? null : "s3://${var.uc_catalog_name}/"
  properties = {
    purpose = "Catalog for workspace - ${var.workspace_id}"
  }
  depends_on = [databricks_external_location.workspace_catalog_external_location]
}

# Set Workspace Catalog as Default
resource "databricks_default_namespace_setting" "this" {
  namespace {
    value = local.uc_catalog_name_us
  }
}

# Grant Admin Catalog Perms
resource "databricks_grant" "workspace_catalog" {
  catalog = databricks_catalog.workspace_catalog.name

  principal  = var.user_workspace_catalog_admin
  privileges = ["ALL_PRIVILEGES"]
}

# =============================================================================
# State Moves
# =============================================================================

# The AWS-backed resources are now count-gated on is_serverless. Migrate existing (HYBRID) state from
# the previously un-counted addresses to index [0]. Combined with the module-level moved block in the
# root configuration, existing deployments migrate without destroy/recreate.
moved {
  from = null_resource.previous
  to   = null_resource.previous[0]
}

moved {
  from = time_sleep.wait_60_seconds
  to   = time_sleep.wait_60_seconds[0]
}

moved {
  from = aws_kms_key.catalog_storage
  to   = aws_kms_key.catalog_storage[0]
}

moved {
  from = aws_kms_alias.catalog_storage_key_alias
  to   = aws_kms_alias.catalog_storage_key_alias[0]
}

moved {
  from = databricks_storage_credential.workspace_catalog_storage_credential
  to   = databricks_storage_credential.workspace_catalog_storage_credential[0]
}

moved {
  from = aws_iam_policy.unity_catalog
  to   = aws_iam_policy.unity_catalog[0]
}

moved {
  from = aws_iam_role.unity_catalog
  to   = aws_iam_role.unity_catalog[0]
}

moved {
  from = aws_iam_policy_attachment.unity_catalog_attach
  to   = aws_iam_policy_attachment.unity_catalog_attach[0]
}

moved {
  from = aws_s3_bucket.unity_catalog_bucket
  to   = aws_s3_bucket.unity_catalog_bucket[0]
}

moved {
  from = aws_s3_bucket_versioning.unity_catalog_versioning
  to   = aws_s3_bucket_versioning.unity_catalog_versioning[0]
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.unity_catalog
  to   = aws_s3_bucket_server_side_encryption_configuration.unity_catalog[0]
}

moved {
  from = aws_s3_bucket_public_access_block.unity_catalog
  to   = aws_s3_bucket_public_access_block.unity_catalog[0]
}

moved {
  from = databricks_external_location.workspace_catalog_external_location
  to   = databricks_external_location.workspace_catalog_external_location[0]
}
