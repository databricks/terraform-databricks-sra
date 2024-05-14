// EXPLANATION: Create the customer managed-vpc and security group rules

// VPC and other assets - skipped entirely in custom mode, some assets skipped for firewall and isolated
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  count = var.operation_mode != "custom" ? 1 : 0

  name = "${var.resource_prefix}-data-plane-VPC"
  cidr = var.vpc_cidr_range
  azs  = var.availability_zones

  enable_dns_hostnames   = true
  enable_nat_gateway     = var.operation_mode == "firewall" || var.operation_mode == "isolated" ? false : true
  single_nat_gateway     = false
  one_nat_gateway_per_az = var.operation_mode == "firewall" || var.operation_mode == "isolated" ? false : true
  create_igw             = var.operation_mode == "firewall" || var.operation_mode == "isolated" ? false : true

  public_subnet_names = var.operation_mode == "firewall" || var.operation_mode == "isolated" ? [] : [for az in var.availability_zones : format("%s-public-%s", var.resource_prefix, az)]
  public_subnets      = var.operation_mode == "firewall" || var.operation_mode == "isolated" ? [] : var.public_subnets_cidr

  private_subnet_names = [for az in var.availability_zones : format("%s-private-%s", var.resource_prefix, az)]
  private_subnets      = var.private_subnets_cidr

  intra_subnet_names = [for az in var.availability_zones : format("%s-privatelink-%s", var.resource_prefix, az)]
  intra_subnets      = var.privatelink_subnets_cidr
}


// Security group - skipped in custom mode
resource "aws_security_group" "sg" {
  count = var.operation_mode != "custom" ? 1 : 0

  vpc_id     = module.vpc[0].vpc_id
  depends_on = [module.vpc]

  dynamic "ingress" {
    for_each = var.sg_ingress_protocol
    content {
      description = "Databricks - Data Plane Security Group - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = ingress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocol
    content {
      description = "Databricks - Data Plane Security Group - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = egress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      description = "Databricks - Data Plane Security Group - REST (443), Secure Cluster Connectivity (6666), Future Extendability (8443-8451)"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

    dynamic "egress" {
     for_each = var.compliance_security_profile ? [2443] : []
    
    content {
      description       = "Databricks - Data Plane Security Group -  FIPS encryption"      
      from_port         = 2443
      to_port           = 2443
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "${var.resource_prefix}-data-plane-sg"
  }
}