resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}


// Unity Catalog Trust Policy
data "aws_iam_policy_document" "passrole_for_unity_catalog_catalog" {
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
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-unity-catalog-${var.workspace_id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Unity Catalog Role
resource "aws_iam_role" "unity_catalog_role" {
  name               = "${var.resource_prefix}-unity-catalog-${var.workspace_id}"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_unity_catalog_catalog.json
  tags = {
    Name = "${var.resource_prefix}-unity-catalog"
  }
}

// Unity Catalog IAM Policy
data "aws_iam_policy_document" "unity_catalog_iam_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.uc_catalog_name}/*",
      "arn:aws:s3:::${var.uc_catalog_name}"
    ]

    effect = "Allow"
  }

  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-unity-catalog-${var.workspace_id}"]
    effect    = "Allow"
  }
}

// Unity Catalog Policy
resource "aws_iam_role_policy" "unity_catalog" {
  name   = "${var.resource_prefix}-unity-catalog-policy-${var.workspace_id}"
  role   = aws_iam_role.unity_catalog_role.id
  policy = data.aws_iam_policy_document.unity_catalog_iam_policy.json
}


// Unity Catalog S3
resource "aws_s3_bucket" "unity_catalog_bucket" {
  bucket        = var.uc_catalog_name
  force_destroy = true
  tags = {
    Name = var.uc_catalog_name
  }
}

resource "aws_s3_bucket_versioning" "unity_catalog_versioning" {
  bucket = aws_s3_bucket.unity_catalog_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "unity_catalog" {
  bucket = aws_s3_bucket.unity_catalog_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "unity_catalog" {
  bucket                  = aws_s3_bucket.unity_catalog_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.unity_catalog_bucket]
}

// Storage Credential
resource "databricks_storage_credential" "workspace_catalog_storage_credential" {
  name = aws_iam_role.unity_catalog_role.name
  aws_iam_role {
    role_arn = aws_iam_role.unity_catalog_role.arn
  }
  depends_on = [aws_iam_role.unity_catalog_role, time_sleep.wait_30_seconds]
}

// External Location
resource "databricks_external_location" "workspace_catalog_external_location" {
  name            = var.uc_catalog_name
  url             = "s3://${var.uc_catalog_name}/catalog/"
  credential_name = databricks_storage_credential.workspace_catalog_storage_credential.id
  skip_validation = true
  read_only       = false
  comment         = "Managed by TF"
}


// Workspace Catalog
resource "databricks_catalog" "workspace_catalog" {
  name           = var.uc_catalog_name
  comment        = "This catalog is for workspace - ${var.workspace_id}"
  isolation_mode = "ISOLATED"
  storage_root   = "s3://${var.uc_catalog_name}/catalog/"
  properties = {
    purpose = "Catalog for workspace - ${var.workspace_id}"
  }
  depends_on = [databricks_external_location.workspace_catalog_external_location]
}

// Grant Admin Catalog Perms
resource "databricks_grant" "workspace_catalog" {
  catalog = databricks_catalog.workspace_catalog.name

  principal  = var.workspace_catalog_admin
  privileges = ["ALL_PRIVILEGES"]
}
