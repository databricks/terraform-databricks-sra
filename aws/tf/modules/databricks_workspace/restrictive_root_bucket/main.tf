# EXPLANATION: Creates a restrictive root bucket policy

locals {
  # Compute the correct Databricks account ID based on GovCloud shard
  databricks_aws_account_id = var.databricks_gov_shard == "civilian" ? "044793339203" : (
    var.databricks_gov_shard == "dod" ? "170661010020" : "414351767826"
  )
}

# Restrictive Bucket Policy
resource "aws_s3_bucket_policy" "databricks_bucket_restrictive_policy" {
  bucket = var.root_s3_bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Grant Databricks Read Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:${var.aws_partition}:iam::${local.databricks_aws_account_id}:root"
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}"
        ],
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/DatabricksAccountId" = var.databricks_account_id
          }
        }
      },
      {
        Sid    = "Grant Databricks Write Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:${var.aws_partition}:iam::${local.databricks_aws_account_id}:root"
        },
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/0_databricks_dev",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/ephemeral/${var.region_name}-prod/${var.workspace_id}/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}.*/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/init/*/*.sh",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/*-*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*__PLACEHOLDER__/",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/*__PLACEHOLDER__/",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/FileStore/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/mlflow/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/mlflow-*/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/mlflow-*/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/pipelines/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/local_disk0/tmp/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/tmp/*"
        ],
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/DatabricksAccountId" = var.databricks_account_id
          }
        }
      },
      {
        Sid       = "AllowSSLRequestsOnly",
        Effect    = "Deny",
        Action    = ["s3:*"],
        Principal = "*",
        Resource = [
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}/*",
          "arn:${var.aws_partition}:s3:::${var.root_s3_bucket}"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
