// EXPLANATION: Create the workspace root bucket

resource "aws_s3_bucket" "root_storage_bucket" {
  bucket        = "${var.resource_prefix}-workspace-root-storage"
  force_destroy = true
  tags = {
    Name    = "${var.resource_prefix}-workspace-root-storage"
    Project = var.resource_prefix
  }
}

resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Disabled"
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

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:DeleteObject"]
    resources = [
      "${aws_s3_bucket.root_storage_bucket.arn}/*",
      aws_s3_bucket.root_storage_bucket.arn]
    principals {
      identifiers = ["arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:root"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/DatabricksAccountId"

      values = [
        var.databricks_account_id
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.aws_iam_policy_document.this.json
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]

  lifecycle {
    ignore_changes = [policy]
  }
}