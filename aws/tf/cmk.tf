# EXPLANATION: The customer-managed keys for workspace and managed services

locals {
  # Null when no CMK admin ARN or AWS account is provided (serverless-only deployments); every consumer
  # of this local is skipped in that mode.
  cmk_admin_value = var.cmk_admin_arn != null ? var.cmk_admin_arn : (
    var.aws_account_id != null ? "arn:${local.computed_aws_partition}:iam::${var.aws_account_id}:root" : null
  )
}

resource "aws_kms_key" "workspace_storage" {
  count               = local.is_serverless ? 0 : 1
  description         = "KMS key for databricks workspace storage"
  enable_key_rotation = true
  policy = jsonencode({
    Version : "2012-10-17",
    "Id" : "key-policy-workspace-storage",
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
        "Sid" : "Allow Databricks to use KMS key for DBFS",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:${local.computed_aws_partition}:iam::${local.databricks_aws_account_id}:root"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:PrincipalTag/DatabricksAccountId" : [var.databricks_account_id]
          }
        }
      },
      {
        "Sid" : "Allow Databricks to use KMS key for EBS",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_iam_role.cross_account_role[0].arn
        },
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "ForAnyValue:StringLike" : {
            "kms:ViaService" : "ec2.*.amazonaws.com"
          }
        }
      }
    ]
  })
  depends_on = [aws_iam_role.cross_account_role]

  tags = {
    Name    = "${var.resource_prefix}-workspace-storage-key"
    Project = var.resource_prefix
  }
}


resource "aws_kms_alias" "workspace_storage_key_alias" {
  count         = local.is_serverless ? 0 : 1
  name          = "alias/${var.resource_prefix}-workspace-storage-key"
  target_key_id = aws_kms_key.workspace_storage[0].id
}

# CMK for Managed Services

resource "aws_kms_key" "managed_services" {
  count               = local.is_serverless ? 0 : 1
  description         = "KMS key for managed services"
  enable_key_rotation = true
  policy = jsonencode({ Version : "2012-10-17",
    "Id" : "key-policy-managed-services",
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
        "Sid" : "Allow Databricks to use KMS key for managed services in the control plane",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:${local.computed_aws_partition}:iam::${local.databricks_aws_account_id}:root"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:PrincipalTag/DatabricksAccountId" : [var.databricks_account_id]
          }
        }
      }
    ]
    }
  )

  tags = {
    Project = var.resource_prefix
    Name    = "${var.resource_prefix}-managed-services-key"
  }
}

resource "aws_kms_alias" "managed_services_key_alias" {
  count         = local.is_serverless ? 0 : 1
  name          = "alias/${var.resource_prefix}-managed-services-key"
  target_key_id = aws_kms_key.managed_services[0].key_id
}
# Preserve state across count addition for the serverless workspace variant
moved {
  from = aws_kms_key.workspace_storage
  to   = aws_kms_key.workspace_storage[0]
}

moved {
  from = aws_kms_alias.workspace_storage_key_alias
  to   = aws_kms_alias.workspace_storage_key_alias[0]
}

moved {
  from = aws_kms_key.managed_services
  to   = aws_kms_key.managed_services[0]
}

moved {
  from = aws_kms_alias.managed_services_key_alias
  to   = aws_kms_alias.managed_services_key_alias[0]
}
