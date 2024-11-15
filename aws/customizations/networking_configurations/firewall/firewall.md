### Firewall (Limited Egress)
Using a firewall networking configuration restricts traffic flow to a specified list of public addresses. This setup is applicable in situations where open internet access is necessary for certain tasks, but unfiltered traffic is not an option due to workload or data sensitivity.

- **WARNING**: Due to a limitation in AWS Network Firewall's support for fully qualified domain names (FQDNs) in non-HTTP/HTTPS traffic, an IP address is required to allow communication with the Hive Metastore. This reliance on a static IP introduces the potential for downtime if the Hive Metastore's IP changes. For sensitive production workloads, it is recommended to explore the isolated operation mode or consider alternative firewall solutions that provide better handling of dynamic IPs or FQDNs.


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
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  create_igw             = false

  public_subnet_names = []
  public_subnets      = []

  private_subnet_names = [for az in var.availability_zones : format("%s-private-%s", var.resource_prefix, az)]
  private_subnets      = var.private_subnets_cidr

  intra_subnet_names = [for az in var.availability_zones : format("%s-privatelink-%s", var.resource_prefix, az)]
  intra_subnets      = var.privatelink_subnets_cidr

  tags = {
    Project = var.resource_prefix
  }
}
```
2. Create a new directory `modules/sra/firewall`
3. Create a new file `modules/sra/firewall.tf`
4. Add the following code block into `modules/sra/firewall.tf`
```
module "harden_firewall" {
  count  = var.operation_mode == "firewall" ? 1 : 0
  source = "./data_plane_hardening/firewall"
  providers = {
    aws = aws
  }

  vpc_id                = module.vpc[0].vpc_id
  vpc_cidr_range        = var.vpc_cidr_range
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = module.vpc[0].private_subnets_cidr_blocks
  private_subnet_rt     = module.vpc[0].private_route_table_ids
  firewall_subnets_cidr = <list(string) of subnets>
  firewall_allow_list   = <list(string) of allowed FQDNs>
  hive_metastore_fqdn   = <HMS FQDN from: https://docs.databricks.com/en/resources/ip-domain-region.html#rds-addresses-for-legacy-hive-metastore>
  availability_zones    = var.availability_zones
  region                = var.region
  resource_prefix       = var.resource_prefix

  depends_on = [module.databricks_mws_workspace]
}
```
