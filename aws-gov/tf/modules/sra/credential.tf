# EXPLANATION: The cross-account role for the Databricks workspace

# Cross Account Trust Policy
data "aws_iam_policy_document" "passrole_for_cross_account_credential" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws-us-gov:iam::${var.databricks_prod_aws_account_id[var.databricks_gov_shard]}:root"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

# Cross Account Role
resource "aws_iam_role" "cross_account_role" {
  name               = "${var.resource_prefix}-cross-account"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_cross_account_credential.json
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
        "Sid" : "NonResourceBasedPermissions",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CancelSpotInstanceRequests",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeIamInstanceProfileAssociations",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
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
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:RequestSpotInstances"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "InstancePoolsSupport",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AssociateIamInstanceProfile",
          "ec2:DisassociateIamInstanceProfile",
          "ec2:ReplaceIamInstanceProfileAssociation"
        ],
        "Resource" : "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:instance/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "AllowEc2RunInstancePerTag",
        "Effect" : "Allow",
        "Action" : "ec2:RunInstances",
        "Resource" : [
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:instance/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/Vendor" : "Databricks"
        } }
      },
      {
        "Sid" : "AllowEc2RunInstancePerVPCid",
        "Effect" : "Allow",
        "Action" : "ec2:RunInstances",
        "Resource" : [
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:subnet/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:security-group/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:vpc" : "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:vpc/${var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id}"
          }
        }
      },
      {
        "Sid" : "AllowEc2RunInstanceOtherResources",
        "Effect" : "Allow",
        "Action" : "ec2:RunInstances",
        "NotResource" : [
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:subnet/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:security-group/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:instance/*"
        ]
      },
      {
        "Sid" : "DatabricksSuppliedImages",
        "Effect" : "Deny",
        "Action" : "ec2:RunInstances",
        "Resource" : [
          "arn:aws-us-gov:ec2:*:*:image/*"
        ],
        "Condition" : {
          "StringNotEquals" : {
            "ec2:Owner" : "044732911619"
          }
        }
      },
      {
        "Sid" : "EC2TerminateInstancesTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:TerminateInstances"
        ],
        "Resource" : [
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:instance/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "EC2AttachDetachVolumeTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AttachVolume",
          "ec2:DetachVolume"
        ],
        "Resource" : [
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:volume/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "EC2CreateVolumeByTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateVolume"
        ],
        "Resource" : [
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:volume/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "EC2DeleteVolumeByTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DeleteVolume"
        ],
        "Resource" : [
          "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:volume/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole",
          "iam:PutRolePolicy"
        ],
        "Resource" : "arn:aws-us-gov:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
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
        "Resource" : "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:security-group/${var.custom_sg_id != null ? var.custom_sg_id : aws_security_group.sg[0].id}",
        "Condition" : {
          "StringEquals" : {
            "ec2:vpc" : "arn:aws-us-gov:ec2:${var.region}:${var.aws_account_id}:vpc/${var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id}"
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