# EXPLANATION: Log S3 object-level (data) events for the Databricks buckets to a dedicated CloudTrail trail

locals {
  # Plan-time decision from plain variables only, so the counts below never depend on unknown values. The audit log
  # delivery bucket only exists when this deployment creates it.
  cloudtrail_audit_log_delivery_bucket = var.cloudtrail_s3_data_events.audit_log_delivery_bucket && !var.audit_log_delivery_exists
  cloudtrail_enabled = !local.is_serverless && (
    local.cloudtrail_audit_log_delivery_bucket || var.cloudtrail_s3_data_events.catalog_bucket || var.cloudtrail_s3_data_events.workspace_root_bucket
  )

  # The log bucket and its CMK are only created when the customer does not bring their own log bucket.
  cloudtrail_create_log_bucket = local.cloudtrail_enabled && var.cloudtrail_s3_data_events.existing_log_bucket_name == null

  cloudtrail_logged_bucket_names = compact([
    local.cloudtrail_audit_log_delivery_bucket ? one(module.log_delivery[*].bucket_name) : null,
    var.cloudtrail_s3_data_events.catalog_bucket ? module.unity_catalog_catalog_creation.catalog_bucket_name : null,
    var.cloudtrail_s3_data_events.workspace_root_bucket ? one(aws_s3_bucket.root_storage_bucket[*].bucket) : null,
  ])

  # Built from its parts rather than read from the trail, since the bucket and key policies must exist before the
  # trail. Null when the trail is skipped, as aws_account_id may be null in SERVERLESS mode.
  cloudtrail_name      = "${var.resource_prefix}-s3-data-events"
  cloudtrail_trail_arn = local.cloudtrail_enabled ? "arn:${local.computed_aws_partition}:cloudtrail:${var.region}:${var.aws_account_id}:trail/${local.cloudtrail_name}" : null
}

# The audit log delivery bucket is not created when audit_log_delivery_exists is true, so it cannot be logged.
check "cloudtrail_audit_log_delivery_bucket" {
  assert {
    condition     = !(var.cloudtrail_s3_data_events.audit_log_delivery_bucket && var.audit_log_delivery_exists)
    error_message = "cloudtrail_s3_data_events.audit_log_delivery_bucket is ignored because audit_log_delivery_exists is true, so this deployment does not create the audit log delivery bucket."
  }
}

resource "aws_cloudtrail" "s3_data_events" {
  count                         = local.cloudtrail_enabled ? 1 : 0
  name                          = local.cloudtrail_name
  s3_bucket_name                = local.cloudtrail_create_log_bucket ? aws_s3_bucket.cloudtrail[0].id : var.cloudtrail_s3_data_events.existing_log_bucket_name
  kms_key_id                    = local.cloudtrail_create_log_bucket ? aws_kms_key.cloudtrail[0].arn : var.cloudtrail_s3_data_events.existing_kms_key_arn
  enable_log_file_validation    = true
  include_global_service_events = false
  is_multi_region_trail         = false

  # Data events only. Management events are left to the account's existing trails.
  advanced_event_selector {
    name = "S3 data events for Databricks buckets"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    field_selector {
      field       = "resources.ARN"
      starts_with = [for bucket in local.cloudtrail_logged_bucket_names : "arn:${local.computed_aws_partition}:s3:::${bucket}/"]
    }
  }

  tags = {
    Name    = local.cloudtrail_name
    Project = var.resource_prefix
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# CMK for CloudTrail log files
resource "aws_kms_key" "cloudtrail" {
  count               = local.cloudtrail_create_log_bucket ? 1 : 0
  description         = "KMS key for CloudTrail S3 data event logs"
  enable_key_rotation = true
  policy = jsonencode({
    Version : "2012-10-17",
    "Id" : "key-policy-cloudtrail",
    Statement : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [local.cmk_admin_value]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow CloudTrail to encrypt logs",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "kms:GenerateDataKey*",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceArn" : local.cloudtrail_trail_arn,
            "kms:EncryptionContext:aws:cloudtrail:arn" : local.cloudtrail_trail_arn
          }
        }
      },
      {
        "Sid" : "Allow CloudTrail to describe key",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "kms:DescribeKey",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceArn" : local.cloudtrail_trail_arn
          }
        }
      }
    ]
  })

  tags = {
    Name    = "${var.resource_prefix}-cloudtrail-key"
    Project = var.resource_prefix
  }
}

resource "aws_kms_alias" "cloudtrail_key_alias" {
  count         = local.cloudtrail_create_log_bucket ? 1 : 0
  name          = "alias/${var.resource_prefix}-cloudtrail-key"
  target_key_id = aws_kms_key.cloudtrail[0].id
}

resource "aws_s3_bucket" "cloudtrail" {
  count         = local.cloudtrail_create_log_bucket ? 1 : 0
  bucket        = "${var.resource_prefix}-cloudtrail-logs"
  force_destroy = true
  tags = {
    Name    = "${var.resource_prefix}-cloudtrail-logs"
    Project = var.resource_prefix
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = local.cloudtrail_create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.cloudtrail[0].arn
        Condition = {
          StringEquals = { "aws:SourceArn" = local.cloudtrail_trail_arn }
        }
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail[0].arn}/AWSLogs/${var.aws_account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = local.cloudtrail_trail_arn
            "s3:x-amz-acl"  = "bucket-owner-full-control"
          }
        }
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.cloudtrail]
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count                   = local.cloudtrail_create_log_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.cloudtrail[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.cloudtrail]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = local.cloudtrail_create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cloudtrail[0].arn
    }
  }
  depends_on = [aws_kms_alias.cloudtrail_key_alias]
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count  = local.cloudtrail_create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id
  versioning_configuration {
    status = "Disabled"
  }
}
