# =============================================================================
# Serverless PrivateLink + Unity Catalog connection to an existing Oracle database
#
# AWS side - implements steps 1 and 2 of:
# https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network
#
# Step 1: Create an internal Network Load Balancer (NLB) that fronts the Oracle
#         TCPS (TLS) listener over TCP.
# Step 2: Create a VPC endpoint service (powered by AWS PrivateLink) over the
#         NLB, with the Databricks serverless private-connectivity role allowlisted.
#
# Databricks side:
# - A private endpoint rule on the workspace's existing Network Connectivity
#   Configuration (NCC) so serverless compute resolves the Oracle host to the
#   endpoint service.
# - A Unity Catalog connection (TYPE ORACLE, TLS) and a foreign catalog over it,
#   usable for Lakehouse Federation and Lakeflow Connect CDC ingestion.
#
# The Oracle database itself is assumed to exist. To stand up a throwaway Amazon
# RDS for Oracle instance for testing, see the example_db subfolder.
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

  # Databricks account console host, selected by GovCloud shard (matches the main SRA config).
  databricks_account_host = var.databricks_gov_shard == "dod" ? "https://accounts-dod.cloud.databricks.mil" : (
    var.databricks_gov_shard == "civilian" ? "https://accounts.cloud.databricks.us" : "https://accounts.cloud.databricks.com"
  )

  # NLB advertises the database on nlb_port (defaults to the native oracle_port).
  nlb_port = var.nlb_port != null ? var.nlb_port : var.oracle_port
}

# -----------------------------------------------------------------------------
# Step 1: Internal Network Load Balancer fronting the Oracle TCPS listener
# -----------------------------------------------------------------------------

resource "aws_lb" "oracle" {
  name                             = "sra-oracle-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.nlb_subnet_ids
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "sra-oracle-nlb"
    Project = var.resource_prefix
  }
}

# IP target group: TCP to the Oracle database's private IP and TCPS port.
resource "aws_lb_target_group" "oracle" {
  name        = "sra-oracle-tg"
  port        = var.oracle_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = tostring(var.oracle_port)
    interval            = var.health_check_interval
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "sra-oracle-tg"
    Project = var.resource_prefix
  }
}

resource "aws_lb_target_group_attachment" "oracle" {
  target_group_arn = aws_lb_target_group.oracle.arn
  target_id        = var.oracle_ip_address
  port             = var.oracle_port
}

# Listener on the advertised NLB port, forwarding to the Oracle target group.
resource "aws_lb_listener" "oracle" {
  load_balancer_arn = aws_lb.oracle.arn
  port              = local.nlb_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oracle.arn
  }
}

# -----------------------------------------------------------------------------
# Step 2: VPC endpoint service (AWS PrivateLink) over the NLB
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint_service" "oracle" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [aws_lb.oracle.arn]

  tags = {
    Name    = "${var.resource_prefix}-oracle-endpoint-service"
    Project = var.resource_prefix
  }
}

# Allowlist the Databricks serverless private-connectivity role (or a custom set
# of principals) so Databricks can create an interface endpoint to this service.
resource "aws_vpc_endpoint_service_allowed_principal" "databricks" {
  for_each = toset(local.allowed_principals)

  vpc_endpoint_service_id = aws_vpc_endpoint_service.oracle.id
  principal_arn           = each.value
}

# -----------------------------------------------------------------------------
# Databricks: NCC private endpoint rule (account-level)
# -----------------------------------------------------------------------------

# Points the workspace's existing NCC at the endpoint service. domain_names carries
# the Oracle hostname so serverless resolves it to the private endpoint. Stays
# PENDING until the endpoint connection is accepted (automatic when
# acceptance_required = false).
resource "databricks_mws_ncc_private_endpoint_rule" "oracle" {
  provider = databricks.account

  network_connectivity_config_id = var.ncc_id
  endpoint_service               = aws_vpc_endpoint_service.oracle.service_name
  domain_names                   = [var.oracle_host]

  depends_on = [aws_vpc_endpoint_service_allowed_principal.databricks]
}

# -----------------------------------------------------------------------------
# Databricks: Unity Catalog connection + foreign catalog (workspace-level)
# -----------------------------------------------------------------------------

resource "databricks_connection" "oracle" {
  provider = databricks.workspace

  name            = var.connection_name
  connection_type = "ORACLE"
  comment         = "Oracle database via serverless PrivateLink (TLS)"

  # Compliance Security Profile (FIPS) workspaces reject Oracle Native Network
  # Encryption, so connect over TCPS (TLS) and verify the server with the CA
  # chain that signed the Oracle server certificate.
  options = {
    host                          = var.oracle_host
    port                          = tostring(local.nlb_port)
    user                          = var.oracle_user
    password                      = var.oracle_password
    service_name                  = var.oracle_service_name
    encryption_protocol           = "TLS"
    userProvidedServerCertificate = file(var.server_certificate_path)
  }

  # The connection validates connectivity on create, so the PrivateLink path
  # must be provisioned (and accepted) first.
  depends_on = [databricks_mws_ncc_private_endpoint_rule.oracle]
}

resource "databricks_catalog" "oracle" {
  provider = databricks.workspace

  name            = var.foreign_catalog_name
  connection_name = databricks_connection.oracle.name
  comment         = "Foreign catalog over the Oracle connection"

  options = {
    service_name = var.oracle_service_name
  }
}
