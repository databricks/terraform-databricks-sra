# EXPLANATION: All modules that reside at the workspace level

# Creates a Workspace Isolated Catalog
module "uc_catalog" {
  source = "./databricks_workspace/uc_catalog"
  providers = {
    databricks = databricks.created_workspace
  }

  aws_account_id                 = var.aws_account_id
  resource_prefix                = var.resource_prefix
  uc_catalog_name                = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  cmk_admin_arn                  = var.cmk_admin_arn == null ? "arn:aws-us-gov:iam::${var.aws_account_id}:root" : var.cmk_admin_arn
  workspace_id                   = module.databricks_mws_workspace.workspace_id
  user_workspace_catalog_admin   = var.admin_user
<<<<<<< HEAD
  databricks_account_id          = var.databricks_account_id
=======
>>>>>>> c1185b0 (aws gov simplicity update)
  databricks_gov_shard           = var.databricks_gov_shard
  databricks_prod_aws_account_id = var.databricks_prod_aws_account_id
  uc_master_role_id              = var.uc_master_role_id

  depends_on = [module.databricks_mws_workspace, module.uc_assignment]
}

<<<<<<< HEAD
# System Table Schemas Enablement - Coming Soon to AWS-Gov
=======
// System Table Schemas Enablement - Coming Soon to AWS-Gov
>>>>>>> c1185b0 (aws gov simplicity update)
/*
module "system_table" {
  source = "./databricks_workspace/system_schema"
  providers = {
    databricks = databricks.created_workspace
  }
  depends_on = [ module.uc_assignment ]
}
*/

<<<<<<< HEAD
# Create Create Cluster
=======
// Create Create Cluster
>>>>>>> c1185b0 (aws gov simplicity update)
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

<<<<<<< HEAD
# Restrictive DBFS bucket policy
=======
// Restrictive DBFS bucket policy
>>>>>>> c1185b0 (aws gov simplicity update)
module "restrictive_root_bucket" {
  source = "./databricks_workspace/restrictive_root_bucket"
  providers = {
    aws = aws
  }

<<<<<<< HEAD
<<<<<<< HEAD
  databricks_prod_aws_account_id = var.databricks_prod_aws_account_id
  databricks_gov_shard           = var.databricks_gov_shard
  workspace_id          = module.databricks_mws_workspace.workspace_id
  region_name           = var.region_name
  root_s3_bucket        = "${var.resource_prefix}-workspace-root-storage"
  databricks_account_id = var.databricks_account_id

  depends_on = [module.databricks_mws_workspace]
}
=======
  alert_emails = [var.user_workspace_admin]

  depends_on = [
    module.databricks_mws_workspace
  ]
}
>>>>>>> 101e277 (Adding workspace dependency for databricks_workspace.tf)
=======
  databricks_account_id = var.databricks_account_id
  workspace_id          = module.databricks_mws_workspace.workspace_id
  region_name           = var.region_name
  root_s3_bucket        = "${var.resource_prefix}-workspace-root-storage"

  depends_on = [module.databricks_mws_workspace]
}
>>>>>>> c1185b0 (aws gov simplicity update)
