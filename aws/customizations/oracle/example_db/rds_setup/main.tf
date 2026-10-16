# =============================================================================
# Test Oracle database: Amazon RDS for Oracle with a TCPS (TLS) listener
#
# FOR TESTING ONLY. Stands up a throwaway Oracle source so the parent oracle
# customization can be exercised end to end. Customers normally already have the
# Oracle database they want to connect to and should skip this folder.
#
# Creates an Oracle SE2 (license-included) RDS instance with an SSL option group
# exposing TCPS on tls_port, which Compliance Security Profile (FIPS) workspaces
# require. Automated backups stay enabled (backup_retention_period > 0) so the
# instance runs in ARCHIVELOG mode, a Lakeflow Connect CDC prerequisite.
# =============================================================================

resource "aws_db_instance" "oracle" {
  identifier     = "${var.resource_prefix}-oracle"
  engine         = var.oracle_edition
  engine_version = var.engine_version
  instance_class = var.instance_class
  license_model  = "license-included"

  db_name           = var.db_name
  username          = var.master_username
  password          = random_password.master.result
  port              = var.port
  option_group_name = aws_db_option_group.oracle.name

  # Pin the server certificate CA so it matches the bundled PEM (us-gov-west-1)
  # or the regional bundle from the ca_bundle_url output, rather than relying on
  # the regional RDS default, which can change.
  ca_cert_identifier = var.ca_cert_identifier

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.oracle.name
  vpc_security_group_ids = [aws_security_group.oracle.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection

  # Test-friendly teardown. Flip skip_final_snapshot to false (and set
  # final_snapshot_identifier) if you want a snapshot on destroy.
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name    = "${var.resource_prefix}-oracle"
    Project = var.resource_prefix
  }
}

resource "aws_db_option_group" "oracle" {
  name                     = "${var.resource_prefix}-oracle-ssl"
  engine_name              = var.oracle_edition
  major_engine_version     = var.major_engine_version
  option_group_description = "Oracle SSL/TLS (TCPS) for CSP-compliant federation"

  # Enable TLS on tls_port. SQLNET.SSL_VERSION 1.2 is FIPS-acceptable.
  option {
    option_name                    = "SSL"
    port                           = var.tls_port
    vpc_security_group_memberships = [aws_security_group.oracle.id]

    option_settings {
      name  = "SQLNET.SSL_VERSION"
      value = "1.2"
    }
  }

  tags = {
    Project = var.resource_prefix
  }
}

resource "aws_db_subnet_group" "oracle" {
  name       = "${var.resource_prefix}-oracle"
  subnet_ids = var.subnet_ids

  tags = {
    Project = var.resource_prefix
  }
}

resource "aws_security_group" "oracle" {
  name        = "${var.resource_prefix}-oracle"
  description = "Allow Oracle listener access from Databricks compute"
  vpc_id      = var.vpc_id

  # Ingress on both Oracle listeners from allowed CIDRs (e.g. the workspace VPC
  # subnets). The internal NLB for serverless PrivateLink sources traffic from
  # its subnets, so include the NLB subnet CIDRs here for health checks.
  # port (1521) = native; tls_port (2484) = TCPS/TLS.
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? toset([var.port, var.tls_port]) : toset([])
    content {
      description = "Oracle listener ${ingress.value} from allowed CIDRs"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # Ingress on both Oracle listeners from allowed security groups (e.g. the
  # Databricks classic-compute security group).
  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? toset([var.port, var.tls_port]) : toset([])
    content {
      description     = "Oracle listener ${ingress.value} from allowed security groups"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.resource_prefix}-oracle"
    Project = var.resource_prefix
  }
}

resource "random_password" "master" {
  length  = 24
  special = true
  # Oracle disallows a handful of characters in the master password.
  override_special = "_!#$%^&*()-=+[]{}"
}
