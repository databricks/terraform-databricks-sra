# =============================================================================
# Serverless PrivateLink via dbx-proxy (multi-backend / L7)
#
# Wraps the databricks-solutions/dbx-proxy AWS Terraform module. dbx-proxy is a
# HAProxy fleet (EC2 autoscaling group) fronted by an internal NLB and exposed to
# Databricks serverless compute through a VPC endpoint service. Unlike the single-
# backend modules in this folder (rds, kafka, git, s3_interface), it supports
# multiple backends behind one endpoint service and Layer 7 (SNI/HTTP host) routing
# in addition to Layer 4 (TCP).
#
# Use this when serverless compute must reach several private resources through one
# endpoint service, or needs host/SNI-based routing. For a single TCP backend, the
# purpose-built modules in this folder are simpler. Works across commercial and
# GovCloud (civilian/DoD), like the other modules in this folder.
#
# Implements steps 1-2 of:
# https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network
#
# After apply: register the endpoint service name (see the vpc_endpoint_service_name
# output) with your Databricks Network Connectivity Configuration by adding it to the
# SRA serverless_private_endpoint_rules variable, then accept the resulting pending
# connection on this endpoint service (step 5 in the doc).
#
# The Databricks serverless private-connectivity role allowlisted on the VPC endpoint service is
# selected by environment and passed to dbx-proxy via allowed_principals: region distinguishes
# commercial from GovCloud, and databricks_gov_shard distinguishes the civilian vs DoD GovCloud shards.
# =============================================================================

locals {
  # https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network#step-2
  #   - AWS commercial:          arn:aws:iam::565502421330:role/private-connectivity-role-<region>
  #   - AWS GovCloud (Civilian): arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1
  #   - AWS GovCloud (DoD):      arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1
  databricks_private_connectivity_role = var.region == "us-gov-west-1" ? (
    var.databricks_gov_shard == "dod" ? "arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1" : "arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1"
  ) : "arn:aws:iam::565502421330:role/private-connectivity-role-${var.region}"

  allowed_principals = var.allowed_principals != null ? var.allowed_principals : [local.databricks_private_connectivity_role]
}

module "dbx_proxy" {
  # Pinned to the dbx-proxy v0.1.8 release.
  source = "git::https://github.com/databricks-solutions/dbx-proxy.git//terraform/aws?ref=v0.1.8"

  # Naming / tagging
  prefix = var.prefix
  region = var.region
  tags   = merge({ Project = var.resource_prefix }, var.tags)

  # Databricks serverless private-connectivity role (or custom principals) allowlisted on the
  # VPC endpoint service. Selected by region and, for GovCloud, databricks_gov_shard.
  allowed_principals = local.allowed_principals

  # Networking. "bootstrap" creates a VPC/subnets (or uses the ones you pass);
  # "proxy-only" attaches to an existing NLB. See the dbx-proxy README.
  deployment_mode    = var.deployment_mode
  vpc_id             = var.vpc_id
  vpc_cidr           = var.vpc_cidr
  subnet_ids         = var.subnet_ids
  subnet_cidrs       = var.subnet_cidrs
  nat_subnet_cidr    = var.nat_subnet_cidr
  enable_nat_gateway = var.enable_nat_gateway
  nlb_arn            = var.nlb_arn

  # Proxy fleet
  instance_type             = var.instance_type
  min_capacity              = var.min_capacity
  max_capacity              = var.max_capacity
  dbx_proxy_image_version   = var.dbx_proxy_image_version
  dbx_proxy_health_port     = var.dbx_proxy_health_port
  dbx_proxy_max_connections = var.dbx_proxy_max_connections

  # Force the Auto Scaling group to replace every proxy instance every 25 days so it rolls onto the
  # latest patched AMI. This is intentionally hardcoded (not a variable): all SRA users of this proxy
  # get instances rotated on a fixed cadence to satisfy compliance patching mandates (e.g. FedRAMP).
  # 25 days = 2,160,000 seconds.
  max_instance_lifetime = 2160000

  # Listener / routing definition (TCP or HTTP with SNI/host routing)
  dbx_proxy_listener = var.dbx_proxy_listener
}
