module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "${var.resource_prefix}-data-plane-VPC"
  cidr = var.vpc_cidr_range
  azs  = var.availability_zones
  tags = {
    Name = "${var.resource_prefix}-dataplane-vpc"
  }

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  create_igw             = true

  public_subnets = var.public_subnets_cidr
  private_subnets = var.private_subnets_cidr

}

// SG
resource "aws_security_group" "sg" {
  vpc_id = module.vpc.vpc_id
  depends_on  = [module.vpc]

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
    Name = "${var.resource_prefix}-dataplane-sg"
  }
}