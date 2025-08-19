# Security group for privatelink - skipped in custom operation mode

resource "aws_security_group" "privatelink" {
  count  = var.network_configuration != "custom" ? 1 : 0
  name   = "${var.resource_prefix}-privatelink-sg"
  vpc_id = module.vpc[0].vpc_id

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - REST API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  dynamic "ingress" {
    for_each = var.databricks_gov_shard == "civilian" || var.databricks_gov_shard == "dod" ? [] : [1]
    content {
      description     = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity"
      from_port       = 6666
      to_port         = 6666
      protocol        = "tcp"
      security_groups = [aws_security_group.sg[0].id]
    }
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity - Compliance Security Profile"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  ingress {
    description     = "Databricks - Internal calls from the Databricks compute plane to the Databricks control plane API"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  ingress {
    description     = "Databricks - Unity Catalog logging and lineage data streaming into Databricks"
    from_port       = 8444
    to_port         = 8444
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Future Extendability"
    from_port       = 8445
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [aws_security_group.sg[0].id]
  }

  tags = {
    Name    = "${var.resource_prefix}-privatelink-sg",
    Project = var.resource_prefix
  }
}

# EXPLANATION: VPC Gateway Endpoint for S3, Interface Endpoint for Kinesis, and Interface Endpoint for STS

# Restrictive S3 endpoint policy:
data "aws_iam_policy_document" "s3_vpc_endpoint_policy" {
  count = var.network_configuration != "custom" ? 1 : 0

  statement {
    sid    = "Grant access to Workspace Root Bucket"
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
      "arn:${local.computed_aws_partition}:s3:::${var.resource_prefix}-workspace-root-storage/*",
      "arn:${local.computed_aws_partition}:s3:::${var.resource_prefix}-workspace-root-storage"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [local.databricks_aws_account_id]
    }
  }

  statement {
    sid    = "Grant access to Unity Catalog Workspace Catalog Bucket"
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
      "arn:${local.computed_aws_partition}:s3:::${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}/*",
      "arn:${local.computed_aws_partition}:s3:::${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.aws_account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:ResourceAccount"
      values   = [var.aws_account_id]
    }
  }

  statement {
    sid    = "Grant access to Databricks Artifact Buckets"
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

    resources = flatten([
      for bucket in var.artifact_storage_bucket[var.region] : [
        "arn:${local.computed_aws_partition}:s3:::${bucket}/*",
        "arn:${local.computed_aws_partition}:s3:::${bucket}"
      ]
    ])

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.databricks_artifact_and_sample_data_account_id]
    }
  }

  statement {
    sid    = "Grant access to Databricks System Tables Bucket"
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
      "arn:${local.computed_aws_partition}:s3:::${var.databricks_gov_shard == "dod" ? var.system_table_bucket_config[var.region].secondary_bucket : var.system_table_bucket_config[var.region].primary_bucket}/*",
      "arn:${local.computed_aws_partition}:s3:::${var.databricks_gov_shard == "dod" ? var.system_table_bucket_config[var.region].secondary_bucket : var.system_table_bucket_config[var.region].primary_bucket}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [local.databricks_aws_account_id]
    }
  }

  statement {
    sid    = "Grant access to Databricks Sample Data Bucket"
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
      "arn:${local.computed_aws_partition}:s3:::${var.shared_datasets_bucket[var.region]}/*",
      "arn:${local.computed_aws_partition}:s3:::${var.shared_datasets_bucket[var.region]}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [local.databricks_artifact_and_sample_data_account_id]
    }
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
      "arn:${local.computed_aws_partition}:s3:::${var.databricks_gov_shard == "dod" ? var.log_storage_bucket_config[var.region].secondary_bucket : var.log_storage_bucket_config[var.region].primary_bucket}/*",
      "arn:${local.computed_aws_partition}:s3:::${var.databricks_gov_shard == "dod" ? var.log_storage_bucket_config[var.region].secondary_bucket : var.log_storage_bucket_config[var.region].primary_bucket}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [local.databricks_aws_account_id]
    }
  }
}

# Restrictive STS endpoint policy:
data "aws_iam_policy_document" "sts_vpc_endpoint_policy" {
  count = var.network_configuration != "custom" ? 1 : 0

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
      identifiers = [var.aws_account_id]
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
      identifiers = var.region == "us-gov-west-1" ? [local.databricks_aws_account_id] : [
        "arn:${local.computed_aws_partition}:iam::${local.databricks_aws_account_id}:user/databricks-datasets-readonly-user-prod",
        local.databricks_aws_account_id
      ]
    }
  }
}

# Restrictive Kinesis endpoint policy:
data "aws_iam_policy_document" "kinesis_vpc_endpoint_policy" {
  count = var.network_configuration != "custom" ? 1 : 0
  statement {
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:DescribeStream"
    ]
    effect    = "Allow"
    resources = ["arn:${local.computed_aws_partition}:kinesis:${var.region}:${local.databricks_aws_account_id}:stream/*"]

    principals {
      type        = "AWS"
      identifiers = [local.databricks_aws_account_id]
    }
  }
}

# VPC endpoint creation - Skipped in custom operation mode
module "vpc_endpoints" {
  count = var.network_configuration != "custom" ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc[0].vpc_id
  security_group_ids = [aws_security_group.privatelink[0].id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc[0].private_route_table_ids
      policy          = data.aws_iam_policy_document.s3_vpc_endpoint_policy[0].json
      tags = {
        Name    = "${var.resource_prefix}-s3-vpc-endpoint"
        Project = var.resource_prefix
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].intra_subnets
      policy              = data.aws_iam_policy_document.sts_vpc_endpoint_policy[0].json
      tags = {
        Name    = "${var.resource_prefix}-sts-vpc-endpoint"
        Project = var.resource_prefix
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].intra_subnets
      policy              = data.aws_iam_policy_document.kinesis_vpc_endpoint_policy[0].json
      tags = {
        Name    = "${var.resource_prefix}-kinesis-vpc-endpoint"
        Project = var.resource_prefix
      }
    }
  }
}

# Databricks REST endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_rest" {
  count = var.network_configuration != "custom" ? 1 : 0

  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.databricks_gov_shard == "dod" ? var.workspace_config[var.region].secondary_endpoint : var.workspace_config[var.region].primary_endpoint
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = module.vpc[0].intra_subnets
  private_dns_enabled = true
  tags = {
    Name    = "${var.resource_prefix}-databricks-backend-rest"
    Project = var.resource_prefix
  }
}

# Databricks SCC endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_relay" {
  count = var.network_configuration != "custom" ? 1 : 0

  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.databricks_gov_shard == "dod" ? var.scc_relay_config[var.region].secondary_endpoint : var.scc_relay_config[var.region].primary_endpoint
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = module.vpc[0].intra_subnets
  private_dns_enabled = true
  tags = {
    Name    = "${var.resource_prefix}-databricks-backend-relay"
    Project = var.resource_prefix
  }
}