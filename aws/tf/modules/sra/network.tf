// EXPLANATION: Create the customer managed-vpc and security group rules

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.resource_prefix}-data-plane-VPC"
  cidr = var.vpc_cidr_range
  azs  = var.availability_zones

  enable_dns_hostnames   = true
  enable_nat_gateway     = var.enable_firewall_boolean ? false : true
  single_nat_gateway     = false
  one_nat_gateway_per_az = var.enable_firewall_boolean ? false : true
  create_igw             = var.enable_firewall_boolean ? false : true

  public_subnet_names = var.enable_firewall_boolean ? [] : [for az in var.availability_zones : format("%s-public-%s", var.resource_prefix, az)]
  public_subnets      = var.enable_firewall_boolean ? [] : var.public_subnets_cidr

  private_subnet_names = [for az in var.availability_zones : format("%s-private-%s", var.resource_prefix, az)]
  private_subnets      = var.private_subnets_cidr

  intra_subnet_names = [for az in var.availability_zones : format("%s-privatelink-%s", var.resource_prefix, az)]
  intra_subnets      = var.privatelink_subnets_cidr
}

// SG
resource "aws_security_group" "sg" {
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]

  dynamic "ingress" {
    for_each = var.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "${var.resource_prefix}-data-plane-sg"
  }
}