# =============================================================================
# Serverless PrivateLink to an internal Kafka cluster (Steps 1-2)
#
# Implements steps 1 and 2 of:
# https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network
#
# Step 1: Create an internal Network Load Balancer (NLB) that fronts your Kafka
#         brokers. Each broker is advertised on its own dedicated NLB port so
#         serverless clients can address individual brokers after bootstrap.
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

  brokers_by_name = { for b in var.brokers : b.name => b }
}

# -----------------------------------------------------------------------------
# Step 1: Internal Network Load Balancer fronting the Kafka brokers
# -----------------------------------------------------------------------------

resource "aws_lb" "kafka" {
  name                             = "sra-kafka-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.nlb_subnet_ids
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "sra-kafka-nlb"
    Project = var.resource_prefix
  }
}

# One IP target group per broker: TCP to the broker's real address/port.
resource "aws_lb_target_group" "kafka" {
  for_each = local.brokers_by_name

  name        = "sra-${each.value.name}"
  port        = each.value.port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = tostring(each.value.port)
    interval            = var.health_check_interval
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "sra-${each.value.name}"
    Project = var.resource_prefix
  }
}

resource "aws_lb_target_group_attachment" "kafka" {
  for_each = local.brokers_by_name

  target_group_arn = aws_lb_target_group.kafka[each.key].arn
  target_id        = each.value.ip_address
  port             = each.value.port
}

# One listener per broker on its dedicated NLB port, forwarding to that broker's
# target group. Serverless clients reach broker N via the endpoint on nlb_port N.
resource "aws_lb_listener" "kafka" {
  for_each = local.brokers_by_name

  load_balancer_arn = aws_lb.kafka.arn
  port              = each.value.nlb_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kafka[each.key].arn
  }
}

# -----------------------------------------------------------------------------
# Step 2: VPC endpoint service (AWS PrivateLink) over the NLB
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint_service" "kafka" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [aws_lb.kafka.arn]

  tags = {
    Name    = "${var.resource_prefix}-kafka-endpoint-service"
    Project = var.resource_prefix
  }
}

# Allowlist the Databricks serverless private-connectivity role (or a custom set
# of principals) so Databricks can create an interface endpoint to this service.
resource "aws_vpc_endpoint_service_allowed_principal" "databricks" {
  for_each = toset(local.allowed_principals)

  vpc_endpoint_service_id = aws_vpc_endpoint_service.kafka.id
  principal_arn           = each.value
}
