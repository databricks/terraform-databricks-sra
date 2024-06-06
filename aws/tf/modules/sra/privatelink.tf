// Security group for privatelink - skipped in custom operation mode
resource "aws_security_group" "privatelink" {
  count = var.operation_mode != "custom" ? 1 : 0

  vpc_id = module.vpc[0].vpc_id

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - REST API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Future Extendability"
    from_port       = 8443
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  dynamic "ingress" {
    for_each = var.compliance_security_profile_egress_ports ? [2443] : []

    content {
      description     = "Databricks - PrivateLink Endpoint SG -  FIPS encryption"
      from_port       = 2443
      to_port         = 2443
      protocol        = "tcp"
      security_groups = [aws_security_group.sg[0].id]
    }
  }

  tags = {
    Name = "${var.resource_prefix}-private-link-sg"
  }
}

// EXPLANATION: VPC Gateway Endpoint for S3, Interface Endpoint for Kinesis, and Interface Endpoint for STS


// Restrictive S3 endpoint policy - only used if restrictive S3 endpoint policy is enabled
data "aws_iam_policy_document" "s3_vpc_endpoint_policy" {
  count = var.enable_restrictive_s3_endpoint_boolean ? 1 : 0

  statement {
    sid    = "Grant access to Databricks Root Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.resource_prefix}-workspace-root-storage}/*",
      "arn:aws:s3:::${var.resource_prefix}-workspace-root-storage}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }

    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:SourceVpc"
      values = [
        module.vpc[0].vpc_id
      ]
    }
  }

  statement {
    sid    = "Grant access to Databricks Unity Catalog Metastore Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}/*",
      "arn:aws:s3:::${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
    ]
  }

  statement {
    sid    = "Grant read-only access to Data Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.read_only_data_bucket}/*",
      "arn:aws:s3:::${var.read_only_data_bucket}"
    ]
  }

  statement {
    sid    = "Grant Databricks Read Access to Artifact and Data Buckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::databricks-prod-artifacts-${var.region}/*",
      "arn:aws:s3:::databricks-prod-artifacts-${var.region}",
      "arn:aws:s3:::databricks-datasets-${var.region_name}/*",
      "arn:aws:s3:::databricks-datasets-${var.region_name}"
    ]
  }

  statement {
    sid    = "Grant access to Databricks Log Bucket"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::databricks-prod-storage-${var.region_name}/*",
      "arn:aws:s3:::databricks-prod-storage-${var.region_name}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }
  }
  depends_on = [module.databricks_mws_workspace]
}

// Restrictive STS endpoint policy - only used if restrictive STS endpoint policy is enabled
data "aws_iam_policy_document" "sts_vpc_endpoint_policy" {
  count = var.enable_restrictive_sts_endpoint_boolean ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:GetAccessKeyInfo",
      "sts:GetSessionToken",
      "sts:DecodeAuthorizationMessage",
      "sts:TagSession"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["${var.aws_account_id}"]
    }
  }

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:GetSessionToken",
      "sts:TagSession"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::414351767826:user/databricks-datasets-readonly-user",
        "414351767826"
      ]
    }
  }
}

// Restrictive Kinesis endpoint policy - only used if restrictive Kinesis endpoint policy is enabled
data "aws_iam_policy_document" "kinesis_vpc_endpoint_policy" {
  count = var.enable_restrictive_kinesis_endpoint_boolean ? 1 : 0

  statement {
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:DescribeStream"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kinesis:${var.region}:414351767826:stream/*"]

    principals {
      type        = "AWS"
      identifiers = ["414351767826"]
    }
  }
}

// VPC endpoint creation - Skipped in custom operation mode
module "vpc_endpoints" {
  count = var.operation_mode != "custom" ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc[0].vpc_id
  security_group_ids = [aws_security_group.privatelink[0].id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc[0].private_route_table_ids
      policy          = var.enable_restrictive_s3_endpoint_boolean ? data.aws_iam_policy_document.s3_vpc_endpoint_policy[0].json : null
      tags = {
        Name = "${var.resource_prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].intra_subnets
      policy              = var.enable_restrictive_sts_endpoint_boolean ? data.aws_iam_policy_document.sts_vpc_endpoint_policy[0].json : null
      tags = {
        Name = "${var.resource_prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].intra_subnets
      policy              = var.enable_restrictive_kinesis_endpoint_boolean ? data.aws_iam_policy_document.kinesis_vpc_endpoint_policy[0].json : null
      tags = {
        Name = "${var.resource_prefix}-kinesis-vpc-endpoint"
      }
    }
  }
  depends_on = [
    module.vpc, module.databricks_mws_workspace
  ]
}

// Databricks REST endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_rest" {
  count = var.operation_mode != "custom" ? 1 : 0

  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.workspace_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = module.vpc[0].intra_subnets
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-backend-rest"
  }
}

// Databricks SCC endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_relay" {
  count = var.operation_mode != "custom" ? 1 : 0

  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.relay_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = module.vpc[0].intra_subnets
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-backend-relay"
  }
}