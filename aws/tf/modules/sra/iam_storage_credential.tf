// Storage Credential Trust Policy
data "aws_iam_policy_document" "passrole_for_storage_credential" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Storage Credential Role
resource "aws_iam_role" "storage_credential_role" {
  name  = "${var.resource_prefix}-storage-credential"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_storage_credential.json
  tags = {
    Name = "${var.resource_prefix}-storage_credential_role"
  }
}


// Storage Credential Policy
resource "aws_iam_role_policy" "storage_credential_policy" {
  name   = "${var.resource_prefix}-storage-credential-policy"
  role   = aws_iam_role.storage_credential_role.id
  policy = jsonencode({Version: "2012-10-17",
            Statement: [
                    {
                        "Action": [
                            "s3:GetObject",
                            "s3:ListBucket",
                            "s3:GetBucketLocation",
                            "s3:GetLifecycleConfiguration",
                        ],
                        "Resource": [
                            "arn:aws:s3:::${var.data_bucket}/*",
                            "arn:aws:s3:::${var.data_bucket}"
                        ],
                        "Effect": "Allow"
                    },
                    {
                        "Action": [
                            "sts:AssumeRole"
                        ],
                        "Resource": [
                            "arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential"
                        ],
                        "Effect": "Allow"
                    }
                  ]
          }
  )
}