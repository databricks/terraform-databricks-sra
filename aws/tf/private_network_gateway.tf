# EXPLANATION: Create the AWS resources for the private network gateway (Private Preview): a gateway subnet, security
# group, and cross-account IAM role that Databricks assumes to manage the gateway network interface. The gateway itself
# is created in the network connectivity configuration module. In SERVERLESS mode no AWS resources are created and the
# customer provides all three.
# https://docs.databricks.com/aws/en/security/network/serverless-network-security/private-network-gateway/configure-private-network-gateway

locals {
  # The gateway is not available in GovCloud, so enabling it there is a no-op. private_network_gateway is only read
  # when the gateway is enabled; otherwise png is null and its contents are ignored.
  png_enabled = var.enable_private_network_gateway && var.region != "us-gov-west-1"
  png         = local.png_enabled ? var.private_network_gateway : null

  # Plan-time decisions from plain variables only, so the counts below never depend on unknown values.
  png_create_role           = local.png != null ? !local.is_serverless && local.png.cross_account_role_arn == null : false
  png_create_security_group = local.png != null ? !local.is_serverless && local.png.security_group_ids == null : false
  png_create_subnet         = local.png != null ? !local.is_serverless && var.network_configuration != "custom" && local.png.subnet_id == null : false
  png_lookup_vpc_cidr       = local.png_create_security_group ? var.network_configuration == "custom" && local.png.egress_cidr_blocks == null : false

  # Security group egress port ranges, from entries such as "443" or "8000-8100".
  png_egress_port_ranges = local.png_create_security_group ? [
    for port in local.png.egress_ports : {
      from = tonumber(split("-", port)[0])
      to   = tonumber(split("-", port)[length(split("-", port)) - 1])
    }
  ] : []

  # The gateway only supports some Availability Zones in some regions. Zone IDs are compared rather than zone names,
  # since names map to different zones in each AWS account.
  png_supported_az_ids = lookup(var.private_network_gateway_supported_az_ids, var.region, null)
  png_subnet_az_id = local.png_create_subnet ? coalesce(local.png.availability_zone_id, try([
    for zone_id in data.aws_availability_zones.available[0].zone_ids : zone_id if local.png_supported_az_ids == null ? true : contains(local.png_supported_az_ids, zone_id)
  ][0], "")) : null

  png_vpc_id = local.is_serverless ? null : (var.network_configuration == "custom" ? var.custom_vpc_id : module.vpc[0].vpc_id)

  # Settings passed to the gateway, or null when it is disabled. The role ARN is read from the wait below so the gateway
  # is only created after the role and its policy have propagated.
  png_gateway = local.png == null ? null : {
    cross_account_role_arn = local.png_create_role ? time_sleep.png_role_propagation[0].triggers["role_arn"] : local.png.cross_account_role_arn
    destinations           = local.png.destinations
    security_group_ids     = local.png_create_security_group ? [aws_security_group.png[0].id] : local.png.security_group_ids
    subnet_id              = local.png_create_subnet ? aws_subnet.png[0].id : local.png.subnet_id
    traffic_mode           = local.png.traffic_mode
  }
}

check "private_network_gateway_govcloud" {
  assert {
    condition     = !(var.enable_private_network_gateway && var.region == "us-gov-west-1")
    error_message = "enable_private_network_gateway is ignored because the private network gateway is not available in GovCloud regions."
  }
}

# Databricks AWS role that assumes the customer's private network gateway role.
data "aws_iam_policy_document" "png_assume_role" {
  count = local.png_create_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["arn:${local.computed_aws_partition}:iam::${local.databricks_aws_account_id}:role/png-management-role"]
      type        = "AWS"
    }

    condition {
      test     = "StringEquals"
      values   = [var.databricks_account_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "png" {
  count              = local.png_create_role ? 1 : 0
  name               = "${var.resource_prefix}-png-role"
  description        = "(${var.resource_prefix}) Private network gateway role"
  assume_role_policy = data.aws_iam_policy_document.png_assume_role[0].json
  tags = {
    Name    = "${var.resource_prefix}-png-role"
    Project = var.resource_prefix
  }
}

# All statements are required by the private network gateway setup guide.
resource "aws_iam_role_policy" "png" {
  count = local.png_create_role ? 1 : 0
  name  = "${var.resource_prefix}-png-policy"
  role  = aws_iam_role.png[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CreateNicInVpc"
        Effect = "Allow"
        Action = "ec2:CreateNetworkInterface"
        Resource = [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:subnet/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:security-group/*"
        ]
      },
      {
        Sid       = "ManageAndCleanupNic"
        Effect    = "Allow"
        Action    = ["ec2:CreateNetworkInterfacePermission", "ec2:DeleteNetworkInterface", "ec2:CreateTags"]
        Resource  = "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:network-interface/*"
        Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      },
      {
        Sid      = "CreateGatewayInVpcOnly"
        Effect   = "Allow"
        Action   = "vpc-lattice:CreateResourceGateway"
        Resource = "arn:${local.computed_aws_partition}:vpc-lattice:${var.region}:${var.aws_account_id}:resourcegateway/*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion"   = var.region
            "aws:RequestTag/Vendor" = "Databricks"
            "vpc-lattice:VpcId"     = local.png_vpc_id
          }
        }
      },
      {
        Sid    = "CreateManagedGatewayResources"
        Effect = "Allow"
        Action = ["vpc-lattice:CreateResourceConfiguration", "vpc-lattice:TagResource"]
        Resource = [
          "arn:${local.computed_aws_partition}:vpc-lattice:${var.region}:${var.aws_account_id}:resourcegateway/*",
          "arn:${local.computed_aws_partition}:vpc-lattice:${var.region}:${var.aws_account_id}:resourceconfiguration/*"
        ]
        Condition = { StringEquals = { "aws:RequestedRegion" = var.region, "aws:RequestTag/Vendor" = "Databricks" } }
      },
      {
        Sid    = "ManageManagedGatewayResources"
        Effect = "Allow"
        Action = [
          "vpc-lattice:GetResourceGateway",
          "vpc-lattice:DeleteResourceGateway",
          "vpc-lattice:GetResourceConfiguration",
          "vpc-lattice:DeleteResourceConfiguration",
          "vpc-lattice:PutResourcePolicy",
          "vpc-lattice:DeleteResourcePolicy"
        ]
        Resource = [
          "arn:${local.computed_aws_partition}:vpc-lattice:${var.region}:${var.aws_account_id}:resourcegateway/*",
          "arn:${local.computed_aws_partition}:vpc-lattice:${var.region}:${var.aws_account_id}:resourceconfiguration/*"
        ]
        Condition = { StringEquals = { "aws:RequestedRegion" = var.region, "aws:ResourceTag/Vendor" = "Databricks" } }
      },
      {
        Sid    = "ListAndDescribeInRegion"
        Effect = "Allow"
        Action = [
          "vpc-lattice:GetResourcePolicy",
          "vpc-lattice:ListResourceGateways",
          "vpc-lattice:ListResourceConfigurations",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRouteTables"
        ]
        Resource  = "*"
        Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      },
      {
        Sid       = "VpcLatticeServiceLinkedRole"
        Effect    = "Allow"
        Action    = "iam:CreateServiceLinkedRole"
        Resource  = "arn:${local.computed_aws_partition}:iam::${var.aws_account_id}:role/aws-service-role/vpc-lattice.amazonaws.com/AWSServiceRoleForVpcLattice"
        Condition = { StringEquals = { "iam:AWSServiceName" = "vpc-lattice.amazonaws.com" } }
      }
    ]
  })
}

# Wait for the new role and its policy to propagate before Databricks assumes it to create the gateway.
resource "time_sleep" "png_role_propagation" {
  count           = local.png_create_role ? 1 : 0
  create_duration = "30s"

  triggers = {
    policy_id = aws_iam_role_policy.png[0].id
    role_arn  = aws_iam_role.png[0].arn
  }
}

# Gateway subnet in the SRA-created VPC. The private preview supports exactly one subnet in one Availability Zone.
resource "aws_subnet" "png" {
  count                = local.png_create_subnet ? 1 : 0
  availability_zone_id = local.png_subnet_az_id
  cidr_block           = local.png.subnet_cidr
  vpc_id               = module.vpc[0].vpc_id
  tags = {
    Name    = "${var.resource_prefix}-png-${local.png_subnet_az_id}"
    Project = var.resource_prefix
  }

  lifecycle {
    precondition {
      condition     = local.png_subnet_az_id != ""
      error_message = "None of this region's available Availability Zones is supported by the private network gateway. Set private_network_gateway.availability_zone_id, or update private_network_gateway_supported_az_ids."
    }
  }
}

# An existing gateway subnet (HYBRID only, since SERVERLESS makes no AWS calls) is checked against the supported zones at
# plan time, instead of failing when Databricks creates the gateway.
data "aws_subnet" "png_existing" {
  count = local.png != null && !local.is_serverless && local.png_supported_az_ids != null ? (local.png.subnet_id != null ? 1 : 0) : 0
  id    = local.png.subnet_id
}

check "private_network_gateway_subnet_zone" {
  assert {
    condition     = length(data.aws_subnet.png_existing) == 0 || contains(coalesce(local.png_supported_az_ids, []), one(data.aws_subnet.png_existing[*].availability_zone_id))
    error_message = "private_network_gateway.subnet_id is in an Availability Zone the private network gateway does not support in this region (see private_network_gateway_supported_az_ids), so creating the gateway will fail."
  }
}

data "aws_vpc" "png" {
  count = local.png_lookup_vpc_cidr ? 1 : 0
  id    = var.custom_vpc_id
}

# Gateway security group: no inbound rules, outbound limited to the destination ports.
resource "aws_security_group" "png" {
  count       = local.png_create_security_group ? 1 : 0
  name        = "${var.resource_prefix}-png-sg"
  description = "Databricks - Private network gateway SG"
  vpc_id      = local.png_vpc_id

  dynamic "egress" {
    for_each = local.png_egress_port_ranges
    content {
      description = egress.value.from == egress.value.to ? "Databricks - Private network gateway SG - Destination port ${egress.value.from}" : "Databricks - Private network gateway SG - Destination ports ${egress.value.from}-${egress.value.to}"
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = "tcp"
      cidr_blocks = coalesce(local.png.egress_cidr_blocks, local.png_lookup_vpc_cidr ? [data.aws_vpc.png[0].cidr_block] : [var.vpc_cidr_range])
    }
  }

  tags = {
    Name    = "${var.resource_prefix}-png-sg"
    Project = var.resource_prefix
  }
}
