# EXPLANATION: The cross-account role for the Databricks workspace

# Cross Account Role
data "databricks_aws_assume_role_policy" "this" {
  external_id   = var.databricks_account_id
  aws_partition = local.assume_role_partition
}

resource "aws_iam_role" "cross_account_role" {
  name               = "${var.resource_prefix}-cross-account"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  tags = {
    Name    = "${var.resource_prefix}-cross-account"
    Project = var.resource_prefix
  }
}

resource "aws_iam_role_policy" "cross_account" {
  name = "${var.resource_prefix}-crossaccount-policy"
  role = aws_iam_role.cross_account_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CreateEC2ResourcesWithRequestTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:CreateVolume",
          "ec2:RequestSpotInstances",
          "ec2:RunInstances"
        ],
        "Resource" : [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:fleet/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:launch-template/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:network-interface/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "AllowDatabricksTagOnCreate",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:launch-template/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:fleet/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:network-interface/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : [
              "CreateFleet",
              "CreateLaunchTemplate",
              "CreateVolume",
              "RequestSpotInstances",
              "RunInstances"
            ],
            "aws:RequestTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "ModifyEC2ResourcesByResourceTags",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AssignPrivateIpAddresses",
          "ec2:AssociateIamInstanceProfile",
          "ec2:AttachVolume",
          "ec2:CancelSpotInstanceRequests",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:DetachVolume",
          "ec2:DisassociateIamInstanceProfile",
          "ec2:ModifyFleet",
          "ec2:ModifyLaunchTemplate",
          "ec2:RequestSpotInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateVolume",
          "ec2:RunInstances"
        ],
        "Resource" : [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:launch-template/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:fleet/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:spot-instance-request/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "GetEC2LaunchTemplateDataByTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:GetLaunchTemplateData"
        ],
        "Resource" : [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:fleet/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "DeleteEC2ResourcesByTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DeleteFleets",
          "ec2:DeleteLaunchTemplate",
          "ec2:DeleteLaunchTemplateVersions",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:TerminateInstances"
        ],
        "Resource" : [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:launch-template/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:fleet/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:spot-instance-request/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "DescribeEC2Resources",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeFleetHistory",
          "ec2:DescribeFleetInstances",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeFleets",
          "ec2:DescribeIamInstanceProfileAssociations",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribePrefixLists",
          "ec2:DescribeReservedInstancesOfferings",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcs",
          "ec2:GetSpotPlacementScores"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowEC2TaggingOnDatabricksResources",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Resource" : [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:launch-template/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:fleet/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:spot-instance-request/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "RestrictAMIUsageToDatabricksDeny",
        "Effect" : "Deny",
        "Action" : [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:RequestSpotInstances"
        ],
        "Resource" : "arn:${local.computed_aws_partition}:ec2:*:*:image/*",
        "Condition" : {
          "StringNotEquals" : {
            "ec2:Owner" : local.databricks_ec2_image_account_id
          }
        }
      },
      {
        "Sid" : "RestrictAMIUsageToDatabricksAllow",
        "Effect" : "Allow",
        "Action" : [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:RequestSpotInstances"
        ],
        "Resource" : "arn:${local.computed_aws_partition}:ec2:*:*:image/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:Owner" : local.databricks_ec2_image_account_id
          }
        }
      },
      {
        "Sid" : "AllowRunInstancesWithScopedResources",
        "Effect" : "Allow",
        "Action" : "ec2:RunInstances",
        "Resource" : [
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:subnet/*",
          "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:security-group/*"
        ],
        "Condition" : {
          "StringEqualsIfExists" : {
            "ec2:vpc" : "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:vpc/${var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id}"
          }
        }
      },
      {
        "Sid" : "IAMRoleForEC2Spot",
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole"
        ],
        "Resource" : [
          "arn:${local.computed_aws_partition}:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
        ],
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : "spot.amazonaws.com"
          }
        }
      },
      {
        "Sid" : "VpcNonresourceSpecificActions",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        "Resource" : "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:security-group/${var.custom_sg_id != null ? var.custom_sg_id : aws_security_group.sg[0].id}",
        "Condition" : {
          "StringEquals" : {
            "ec2:vpc" : "arn:${local.computed_aws_partition}:ec2:${var.region}:${var.aws_account_id}:vpc/${var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id}"
          }
        }
      }
    ]
    }
  )
  depends_on = [
    module.vpc, aws_security_group.sg
  ]
}