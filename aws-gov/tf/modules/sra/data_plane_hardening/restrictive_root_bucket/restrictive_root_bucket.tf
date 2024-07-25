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
          AWS = "arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:root"
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}"
        ]
      },
      {
        Sid    = "Grant Databricks Write Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:root"
        },
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/0_databricks_dev",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/ephemeral/${var.region_name}-prod/${var.workspace_id}/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}.*/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/init/*/*.sh",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/*-*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*__PLACEHOLDER__/",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/user/hive/warehouse/*.db/*__PLACEHOLDER__/",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/FileStore/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/mlflow/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/databricks/mlflow-*/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/mlflow-*/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/pipelines/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/local_disk0/tmp/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/${var.region_name}-prod/${var.workspace_id}/tmp/*"
        ]
      },
      {
        Sid       = "AllowSSLRequestsOnly",
        Effect    = "Deny",
        Action    = ["s3:*"],
        Principal = "*",
        Resource = [
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}/*",
          "arn:aws-us-gov:s3:::${var.root_s3_bucket}"
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