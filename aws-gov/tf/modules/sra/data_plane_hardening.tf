// EXPLANATION: Optional modules that harden the AWS data plane

// Implement an AWS Firewall
module "harden_firewall" {
  count  = var.operation_mode == "firewall" ? 1 : 0
  source = "./data_plane_hardening/firewall"
  providers = {
    aws = aws
  }

  vpc_id                      = module.vpc[0].vpc_id
  vpc_cidr_range              = var.vpc_cidr_range
  public_subnets_cidr         = var.public_subnets_cidr
  private_subnets_cidr        = module.vpc[0].private_subnets_cidr_blocks
  private_subnet_rt           = module.vpc[0].private_route_table_ids
  firewall_subnets_cidr       = var.firewall_subnets_cidr
  firewall_allow_list         = var.firewall_allow_list
  firewall_protocol_deny_list = split(",", var.firewall_protocol_deny_list)
  hive_metastore_fqdn         = var.hive_metastore_fqdn
  availability_zones          = var.availability_zones
  region                      = var.region
  resource_prefix             = var.resource_prefix

  depends_on = [module.databricks_mws_workspace]
}


// Restrictive DBFS bucket policy
module "restrictive_root_bucket" {
  count  = var.enable_restrictive_root_bucket_boolean ? 1 : 0
  source = "./data_plane_hardening/restrictive_root_bucket"
  providers = {
    aws = aws
  }

  workspace_id                   = module.databricks_mws_workspace.workspace_id
  region_name                    = var.region_name
  root_s3_bucket                 = "${var.resource_prefix}-workspace-root-storage"
  databricks_gov_shard           = var.databricks_gov_shard
  databricks_prod_aws_account_id = var.databricks_prod_aws_account_id

  depends_on = [module.databricks_mws_workspace]
}