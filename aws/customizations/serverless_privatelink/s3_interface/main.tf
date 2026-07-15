# =============================================================================
# Serverless PrivateLink to S3 via an interface endpoint (Steps 1-2)
#
# Implements steps 1 and 2 of:
# https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network
#
# NOTE: For most S3 access, Databricks supports a simpler native path - an NCC
# private endpoint rule with resource_names (S3 bucket names) instead of an
# endpoint_service. See the SRA serverless_private_endpoint_rules variable and
# s3_interface.md. Use THIS customization only when you specifically need S3
# reachable through your own VPC endpoint service/NLB (e.g. to funnel S3 traffic
# through the same private path as your other internal services, or to apply
# your own endpoint policy/inspection).
#
# Step 1: Create an S3 interface VPC endpoint in your VPC, then an internal
#         Network Load Balancer (NLB) that fronts the endpoint's ENI IPs on TCP 443.
# Step 2: Create a VPC endpoint service (powered by AWS PrivateLink) over the
#         NLB, with acceptance required and the Databricks serverless
#         private-connectivity role allowlisted.
#
# After apply: register the endpoint service name (see the vpc_endpoint_service_name
# output) with your Databricks Network Connectivity Configuration by adding it to
# the SRA serverless_private_endpoint_rules variable, then accept the resulting
# pending connection on this endpoint service (step 5 in the doc).
# =============================================================================

locals {
  # Databricks serverless stable private-connectivity role to allowlist on the VPC endpoint service.
  # Selected by environment: region distinguishes commercial from GovCloud, and databricks_gov_shard
  # distinguishes the civilian vs DoD GovCloud shards. See:
  # https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network#step-2
  #   - AWS commercial:       arn:aws:iam::565502421330:role/private-connectivity-role-<region>
  #   - AWS GovCloud (Civilian): arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1
  #   - AWS GovCloud (DoD):      arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1
  databricks_private_connectivity_role = var.region == "us-gov-west-1" ? (
    var.databricks_gov_shard == "dod" ? "arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1" : "arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1"
  ) : "arn:aws:iam::565502421330:role/private-connectivity-role-${var.region}"

  allowed_principals = var.allowed_principals != null ? var.allowed_principals : [local.databricks_private_connectivity_role]
}

# -----------------------------------------------------------------------------
# Step 1a: S3 interface VPC endpoint (fronted by the NLB, so private DNS is OFF)
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.s3_endpoint_subnet_ids
  security_group_ids  = var.s3_endpoint_security_group_ids
  private_dns_enabled = false

  tags = {
    Name    = "${var.resource_prefix}-s3-interface-endpoint"
    Project = var.resource_prefix
  }
}

# Look up the private IP of each ENI the interface endpoint created, one per AZ.
# The endpoint creates one ENI per subnet, so the count is known at plan time even
# though the ENI IDs themselves are only known after the endpoint is created.
data "aws_network_interface" "s3" {
  count = length(var.s3_endpoint_subnet_ids)
  id    = tolist(aws_vpc_endpoint.s3.network_interface_ids)[count.index]
}

# -----------------------------------------------------------------------------
# Step 1b: Internal Network Load Balancer fronting the S3 endpoint ENIs on 443
# -----------------------------------------------------------------------------

resource "aws_lb" "s3" {
  name                             = "${var.resource_prefix}-s3-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.nlb_subnet_ids
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "${var.resource_prefix}-s3-nlb"
    Project = var.resource_prefix
  }
}

# IP target group: TLS passthrough (TCP) to the S3 interface endpoint ENIs on 443.
resource "aws_lb_target_group" "s3" {
  name        = "${var.resource_prefix}-s3-tg"
  port        = 443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = "443"
    interval            = var.health_check_interval
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "${var.resource_prefix}-s3-tg"
    Project = var.resource_prefix
  }
}

resource "aws_lb_target_group_attachment" "s3" {
  count = length(data.aws_network_interface.s3)

  target_group_arn = aws_lb_target_group.s3.arn
  target_id        = data.aws_network_interface.s3[count.index].private_ip
  port             = 443
}

# Listener on 443, forwarding to the S3 endpoint target group.
resource "aws_lb_listener" "s3" {
  load_balancer_arn = aws_lb.s3.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.s3.arn
  }
}

# -----------------------------------------------------------------------------
# Step 2: VPC endpoint service (AWS PrivateLink) over the NLB
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint_service" "s3" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [aws_lb.s3.arn]

  tags = {
    Name    = "${var.resource_prefix}-s3-endpoint-service"
    Project = var.resource_prefix
  }
}

# Allowlist the Databricks serverless private-connectivity role (or a custom set
# of principals) so Databricks can create an interface endpoint to this service.
resource "aws_vpc_endpoint_service_allowed_principal" "databricks" {
  for_each = toset(local.allowed_principals)

  vpc_endpoint_service_id = aws_vpc_endpoint_service.s3.id
  principal_arn           = each.value
}
