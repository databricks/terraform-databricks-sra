// EXPLANATION: Create the workspace root bucket

resource "aws_s3_bucket" "root_storage_bucket" {
  bucket        = var.dbfsname
  force_destroy = true
  tags = {
    Name = var.dbfsname
  }
}

resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.workspace_storage.arn
    }
  }
  depends_on = [aws_kms_alias.workspace_storage_key_alias]
}

resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket                  = aws_s3_bucket.root_storage_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.root_storage_bucket]
}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket
}

# Bucket policy to use if the restrictive root bucket is set to false
resource "aws_s3_bucket_policy" "root_bucket_policy" {
  count = var.enable_restrictive_root_bucket_boolean ? 0 : 1

  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.databricks_aws_bucket_policy.this.json
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]
}

# Bucket policy to use if the restrictive root bucket is set to true
resource "aws_s3_bucket_policy" "root_bucket_policy_ignore" {
  count = var.enable_restrictive_root_bucket_boolean ? 1 : 0

  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.databricks_aws_bucket_policy.this.json
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]

  lifecycle {
    ignore_changes = [policy]
  }
}