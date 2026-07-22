# =============================================================================
# Serverless PrivateLink to a self-hosted Git server (Steps 1-2)
#
# Implements the customer-side AWS setup for serverless private Git:
# https://docs.databricks.com/aws/en/repos/serverless-private-git
# which follows steps 1 and 2 of:
# https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network
#
# Step 1: Create an internal Network Load Balancer (NLB) that fronts your
#         self-hosted Git server over TCP. Each configured port (e.g. 443 HTTPS,
#         22 SSH) gets its own listener and target group.
# Step 2: Create a VPC endpoint service (powered by AWS PrivateLink) over the
#         NLB, with acceptance required and the Databricks serverless
#         private-connectivity role allowlisted.
#
# After apply: register the endpoint service name (see the vpc_endpoint_service_name
# output) with your Databricks Network Connectivity Configuration by adding a
# private endpoint rule, accept the resulting pending connection on this endpoint
# service, then (per the serverless private Git docs) wait ~10 minutes and enable
# the Serverless Private Git preview in your workspace settings.
#
# NOTE: A VPC endpoint service can only serve workspaces in its own region; each
# region needs its own NLB and VPC endpoint service.
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

  git_ports = toset([for p in var.git_ports : tostring(p)])
}

# -----------------------------------------------------------------------------
# Step 1: Internal Network Load Balancer fronting the Git server
# -----------------------------------------------------------------------------

resource "aws_lb" "git" {
  name                             = "sra-git-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.nlb_subnet_ids
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "sra-git-nlb"
    Project = var.resource_prefix
  }
}

# One IP target group per Git port: TCP to the Git server's private IP and port.
resource "aws_lb_target_group" "git" {
  for_each = local.git_ports

  name        = "sra-git-${each.value}"
  port        = tonumber(each.value)
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = each.value
    interval            = var.health_check_interval
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "sra-git-${each.value}"
    Project = var.resource_prefix
  }
}

resource "aws_lb_target_group_attachment" "git" {
  for_each = local.git_ports

  target_group_arn = aws_lb_target_group.git[each.value].arn
  target_id        = var.git_ip_address
  port             = tonumber(each.value)
}

# One listener per Git port, forwarding to that port's target group. Serverless
# clients reach the Git server on the same port through the endpoint.
resource "aws_lb_listener" "git" {
  for_each = local.git_ports

  load_balancer_arn = aws_lb.git.arn
  port              = tonumber(each.value)
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.git[each.value].arn
  }
}

# -----------------------------------------------------------------------------
# Step 2: VPC endpoint service (AWS PrivateLink) over the NLB
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint_service" "git" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [aws_lb.git.arn]

  tags = {
    Name    = "${var.resource_prefix}-git-endpoint-service"
    Project = var.resource_prefix
  }
}

# Allowlist the Databricks serverless private-connectivity role (or a custom set
# of principals) so Databricks can create an interface endpoint to this service.
resource "aws_vpc_endpoint_service_allowed_principal" "databricks" {
  for_each = toset(local.allowed_principals)

  vpc_endpoint_service_id = aws_vpc_endpoint_service.git.id
  principal_arn           = each.value
}
