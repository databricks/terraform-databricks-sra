# =============================================================================
# Serverless PrivateLink to an internal RDS instance (Steps 1-2)
#
# Implements steps 1 and 2 of:
# https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network
#
# Step 1: Create an internal Network Load Balancer (NLB) that fronts your RDS
#         instance/cluster endpoint over TCP.
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

  # NLB advertises the database on nlb_port (defaults to the native db_port).
  nlb_port = var.nlb_port != null ? var.nlb_port : var.db_port
}

# -----------------------------------------------------------------------------
# Step 1: Internal Network Load Balancer fronting the RDS endpoint
# -----------------------------------------------------------------------------

resource "aws_lb" "rds" {
  name                             = "sra-rds-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.nlb_subnet_ids
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "sra-rds-nlb"
    Project = var.resource_prefix
  }
}

# IP target group: TCP to the RDS endpoint's private IP and port.
resource "aws_lb_target_group" "rds" {
  name        = "sra-rds-tg"
  port        = var.db_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = tostring(var.db_port)
    interval            = var.health_check_interval
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "sra-rds-tg"
    Project = var.resource_prefix
  }
}

resource "aws_lb_target_group_attachment" "rds" {
  target_group_arn = aws_lb_target_group.rds.arn
  target_id        = var.db_ip_address
  port             = var.db_port
}

# Listener on the advertised NLB port, forwarding to the RDS target group.
resource "aws_lb_listener" "rds" {
  load_balancer_arn = aws_lb.rds.arn
  port              = local.nlb_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rds.arn
  }
}

# -----------------------------------------------------------------------------
# Step 2: VPC endpoint service (AWS PrivateLink) over the NLB
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint_service" "rds" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [aws_lb.rds.arn]

  tags = {
    Name    = "${var.resource_prefix}-rds-endpoint-service"
    Project = var.resource_prefix
  }
}

# Allowlist the Databricks serverless private-connectivity role (or a custom set
# of principals) so Databricks can create an interface endpoint to this service.
resource "aws_vpc_endpoint_service_allowed_principal" "databricks" {
  for_each = toset(local.allowed_principals)

  vpc_endpoint_service_id = aws_vpc_endpoint_service.rds.id
  principal_arn           = each.value
}
