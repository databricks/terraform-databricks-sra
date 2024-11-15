// EXPLANATION: Creates a restrictive root bucket policy

// Restrictive Bucket Policy
resource "aws_s3_bucket_policy" "databricks_bucket_restrictive_policy" {
  bucket = var.root_s3_bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Grant Databricks Read Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::414351767826:root"
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::${var.root_s3_bucket}/*",
          "arn:aws:s3:::${var.root_s3_bucket}"
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
          AWS = "arn:aws:iam::414351767826:root"
        },
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/0_databricks_dev",
          "arn:aws:s3:::${var.root_s3_bucket}/ephemeral/${var.region_name}-prod/${var.workspace_id}/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}.*/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/init/*/*.sh",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/*-*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*__PLACEHOLDER__/",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/*__PLACEHOLDER__/",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/FileStore/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/mlflow/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/mlflow-*/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/mlflow-*/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/pipelines/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/local_disk0/tmp/*",
          "arn:aws:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/tmp/*"
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
          "arn:aws:s3:::${var.root_s3_bucket}/*",
          "arn:aws:s3:::${var.root_s3_bucket}"
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
