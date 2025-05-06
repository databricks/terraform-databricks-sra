# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_log_delivery

# S3 Bucket
resource "aws_s3_bucket" "logdelivery" {
  bucket        = "${var.resource_prefix}-log-delivery"
  force_destroy = true
  tags = {
    Name    = "${var.resource_prefix}-log-delivery"
    Project = var.resource_prefix
  }
}

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "logdelivery" {
  bucket                  = aws_s3_bucket.logdelivery.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.logdelivery]
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "logdelivery_versioning" {
  bucket = aws_s3_bucket.logdelivery.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Bucket Policy Data Source
data "databricks_aws_bucket_policy" "logdelivery" {
  full_access_role = aws_iam_role.logdelivery.arn
  bucket           = aws_s3_bucket.logdelivery.bucket
}

# Bucket Policy
resource "aws_s3_bucket_policy" "logdelivery" {
  bucket = aws_s3_bucket.logdelivery.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [aws_iam_role.logdelivery.arn]
        },
        "Action" : "s3:GetBucketLocation",
        "Resource" : "arn:aws-us-gov:s3:::${var.resource_prefix}-log-delivery"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [aws_iam_role.logdelivery.arn]
        },
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws-us-gov:s3:::${var.resource_prefix}-log-delivery",
          "arn:aws-us-gov:s3:::${var.resource_prefix}-log-delivery/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [aws_iam_role.logdelivery.arn]
        },
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws-us-gov:s3:::${var.resource_prefix}-log-delivery"
      }
    ]
    }
  )
  depends_on = [
    aws_s3_bucket.logdelivery
  ]
}

# Assume Role
data "aws_iam_policy_document" "passrole_for_log_delivery" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:${var.log_delivery_role_name[var.databricks_gov_shard]}"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

# IAM Role
resource "aws_iam_role" "logdelivery" {
  name               = "${var.resource_prefix}-log-delivery-role"
  description        = "(${var.resource_prefix}) UsageDelivery role"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_log_delivery.json
  tags = {
    Name    = "${var.resource_prefix}-logdelivery"
    Project = var.resource_prefix
  }
}

# Wait for Role
resource "time_sleep" "wait" {
  depends_on = [
    aws_iam_role.logdelivery
  ]
  create_duration = "10s"
}

# Log Credential
resource "databricks_mws_credentials" "log_writer" {
  account_id       = var.databricks_account_id
  credentials_name = "Usage Delivery"
  role_arn         = aws_iam_role.logdelivery.arn
  depends_on = [
    time_sleep.wait
  ]
}

# Log Storage Configuration
resource "databricks_mws_storage_configurations" "log_bucket" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = "Usage Logs"
  bucket_name                = aws_s3_bucket.logdelivery.bucket
}

<<<<<<<< Updated upstream:aws-gov/tf/modules/sra/databricks_account/logging_configuration/logging_configuration.tf
// Databricks Billable Usage Logs Configurations
resource "databricks_mws_log_delivery" "billable_usage_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "billable-usage-logs"
  config_name              = "Billable Usage Logs"
  log_type                 = "BILLABLE_USAGE"
  output_format            = "CSV"
  depends_on = [
    aws_s3_bucket_policy.log_delivery
  ]
}

// Databricks Audit Logs Configurations
========
# Log Delivery
>>>>>>>> Stashed changes:aws-gov/tf/modules/sra/databricks_account/audit_log_delivery/main.tf
resource "databricks_mws_log_delivery" "audit_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "audit-logs"
  config_name              = "Audit Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
<<<<<<<< Updated upstream:aws-gov/tf/modules/sra/databricks_account/logging_configuration/logging_configuration.tf
  depends_on = [
    aws_s3_bucket_policy.log_delivery
  ]
========
>>>>>>>> Stashed changes:aws-gov/tf/modules/sra/databricks_account/audit_log_delivery/main.tf
}