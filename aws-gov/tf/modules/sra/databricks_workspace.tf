// EXPLANATION: All modules that reside at the workspace level

// Creates a Workspace Isolated Catalog
module "uc_catalog" {
  source = "./databricks_workspace/uc_catalog"
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_account_id          = var.databricks_account_id
  aws_account_id                 = var.aws_account_id
  resource_prefix                = var.resource_prefix
  uc_catalog_name                = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  cmk_admin_arn                  = var.cmk_admin_arn == null ? "arn:aws-us-gov:iam::${var.aws_account_id}:root" : var.cmk_admin_arn
  workspace_id                   = module.databricks_mws_workspace.workspace_id
  user_workspace_catalog_admin   = var.admin_user
  databricks_gov_shard           = var.databricks_gov_shard
  databricks_prod_aws_account_id = var.databricks_prod_aws_account_id
  uc_master_role_id              = var.uc_master_role_id

  depends_on = [module.databricks_mws_workspace, module.uc_assignment]
}

// System Table Schemas Enablement - Coming Soon to AWS-Gov
/*
module "system_table" {
  source = "./databricks_workspace/system_schema"
  providers = {
    databricks = databricks.created_workspace
  }
  depends_on = [ module.uc_assignment ]
}
*/

// Create Create Cluster
module "cluster_configuration" {
  source = "./databricks_workspace/classic_cluster"
  providers = {
    databricks = databricks.created_workspace
  }

  resource_prefix = var.resource_prefix

  depends_on = [
    module.databricks_mws_workspace, module.vpc_endpoints
  ]
}

// Restrictive DBFS bucket policy
module "restrictive_root_bucket" {
  source = "./databricks_workspace/restrictive_root_bucket"
  providers = {
    aws = aws
  }

  databricks_prod_aws_account_id = var.databricks_account_id
  databricks_gov_shard           = var.databricks_gov_shard
  workspace_id          = module.databricks_mws_workspace.workspace_id
  region_name           = var.region_name
  root_s3_bucket        = "${var.resource_prefix}-workspace-root-storage"

  depends_on = [module.databricks_mws_workspace]
}
