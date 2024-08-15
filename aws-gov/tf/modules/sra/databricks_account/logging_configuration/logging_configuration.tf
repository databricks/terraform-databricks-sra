// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_log_delivery

// S3 Log Bucket
resource "aws_s3_bucket" "log_delivery" {
  bucket        = "${var.resource_prefix}-log-delivery"
  force_destroy = true
  tags = {
    Name = "${var.resource_prefix}-log-delivery"
  }
}

// S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "log_delivery" {
  bucket = aws_s3_bucket.log_delivery.id
  versioning_configuration {
    status = "Disabled"
  }
}

// S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "log_delivery" {
  bucket                  = aws_s3_bucket.log_delivery.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.log_delivery]
}

// S3 Policy for Log Delivery Data
data "databricks_aws_bucket_policy" "log_delivery" {
  full_access_role = aws_iam_role.log_delivery.arn
  bucket           = aws_s3_bucket.log_delivery.bucket
}

// S3 Policy for Log Delivery Resources
resource "aws_s3_bucket_policy" "log_delivery" {
  bucket = aws_s3_bucket.log_delivery.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${aws_iam_role.log_delivery.arn}"]
        },
        "Action" : "s3:GetBucketLocation",
        "Resource" : "arn:aws-us-gov:s3:::${var.resource_prefix}-log-delivery"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${aws_iam_role.log_delivery.arn}"]
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
          "AWS" : ["${aws_iam_role.log_delivery.arn}"]
        },
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws-us-gov:s3:::${var.resource_prefix}-log-delivery"
      }
    ]
    }
  )
  depends_on = [
    aws_s3_bucket.log_delivery
  ]
}

// IAM Role

// Assume Role Policy Log Delivery
data "aws_iam_policy_document" "passrole_for_log_delivery" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:SaasUsageDeliveryRole-prod-aws-gov-IAMRole-L4QM0RCHYQ1G"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Log Delivery IAM Role
resource "aws_iam_role" "log_delivery" {
  name               = "${var.resource_prefix}-log-delivery"
  description        = "(${var.resource_prefix}) Log Delivery Role"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_log_delivery.json
  tags = {
    Name = "${var.resource_prefix}-log-delivery-role"
  }
}

// Databricks Configurations

// Databricks Credential Configuration for Logs
resource "databricks_mws_credentials" "log_writer" {
  credentials_name = "${var.resource_prefix}-log-delivery-credential"
  role_arn         = aws_iam_role.log_delivery.arn
  depends_on = [
    aws_s3_bucket_policy.log_delivery
  ]
}

// Databricks Storage Configuration for Logs
resource "databricks_mws_storage_configurations" "log_bucket" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = "${var.resource_prefix}-log-delivery-bucket"
  bucket_name                = aws_s3_bucket.log_delivery.bucket
  depends_on = [
    aws_s3_bucket_policy.log_delivery
  ]
}

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
resource "databricks_mws_log_delivery" "audit_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "audit-logs"
  config_name              = "Audit Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
  depends_on = [
    aws_s3_bucket_policy.log_delivery
  ]
}
