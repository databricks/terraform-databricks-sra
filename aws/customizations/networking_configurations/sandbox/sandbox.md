### Sandbox (Open Egress)
Using open egress allows traffic to flow freely to the public internet. This networking configuration is suitable for sandbox or development scenarios where data exfiltration protection is of minimal concern, and developers need access to public APIs, packages, and more.


### How to use this network configuration:

1. Replace the VPC module (lines 4-28) in `modules/sra/network.tf` with the following code block:
```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  count = 1

  name = "${var.resource_prefix}-classic-compute-plane-vpc"
  cidr = var.vpc_cidr_range
  azs  = var.availability_zones

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  create_igw             = true

  public_subnet_names = [for az in var.availability_zones : format("%s-public-%s", var.resource_prefix, az)]
  public_subnets      = var.public_subnets_cidr

  private_subnet_names = [for az in var.availability_zones : format("%s-private-%s", var.resource_prefix, az)]
  private_subnets      = var.private_subnets_cidr

  intra_subnet_names = [for az in var.availability_zones : format("%s-privatelink-%s", var.resource_prefix, az)]
  intra_subnets      = var.privatelink_subnets_cidr

  tags = {
    Project = var.resource_prefix
  }
}

```