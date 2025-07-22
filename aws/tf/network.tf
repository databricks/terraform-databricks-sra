# EXPLANATION: Create the customer managed-vpc and security group rules

# VPC and other assets - skipped entirely in custom mode, some assets skipped for firewall and isolated
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"
  count   = var.network_configuration != "custom" ? 1 : 0

  name = "${var.resource_prefix}-classic-compute-plane-vpc"
  cidr = var.vpc_cidr_range
  azs  = data.aws_availability_zones.available.names

  enable_dns_hostnames   = true
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  create_igw             = false

  private_subnet_names = [for az in data.aws_availability_zones.available.names : format("%s-private-%s", var.resource_prefix, az)]
  private_subnets      = var.private_subnets_cidr

  intra_subnet_names = [for az in data.aws_availability_zones.available.names : format("%s-privatelink-%s", var.resource_prefix, az)]
  intra_subnets      = var.privatelink_subnets_cidr

  tags = {
    Project = var.resource_prefix
  }
}


# Security group - skipped in custom mode
resource "aws_security_group" "sg" {
  count  = var.network_configuration != "custom" ? 1 : 0
  name   = "${var.resource_prefix}-workspace-sg"
  vpc_id = module.vpc[0].vpc_id


  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = ingress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = egress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = var.databricks_gov_shard == "civilian" || var.databricks_gov_shard == "dod" ? [for port in var.sg_egress_ports : port if port != 6666] : var.sg_egress_ports
    content {
      description = "Databricks - Workspace SG - REST (443), Secure Cluster Connectivity (2443/6666), Compute Plane to Control Plane Internal Calls (8443), Unity Catalog Logging and Lineage Data Streaming (8444), Future Extendability (8445-8451)"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name    = "${var.resource_prefix}-workspace-sg"
    Project = var.resource_prefix
  }
  depends_on = [module.vpc]
}