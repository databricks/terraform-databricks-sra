# EXPLANATION: All modules that reside at the workspace level

# Creates a Workspace Isolated Catalog
module "uc_catalog" {
  source = "./databricks_workspace/uc_catalog"
  providers = {
    databricks = databricks.created_workspace
  }

  aws_account_id               = var.aws_account_id
  resource_prefix              = var.resource_prefix
  uc_catalog_name              = "${var.resource_prefix}-catalog-${module.databricks_mws_workspace.workspace_id}"
  cmk_admin_arn                = var.cmk_admin_arn == null ? "arn:aws:iam::${var.aws_account_id}:root" : var.cmk_admin_arn
  workspace_id                 = module.databricks_mws_workspace.workspace_id
  user_workspace_catalog_admin = var.admin_user

  depends_on = [module.databricks_mws_workspace, module.uc_assignment]
}

<<<<<<< HEAD
<<<<<<< HEAD
# System Table Schemas Enablement
=======
// System Table Schemas Enablement
>>>>>>> b3e4c6f (aws simplicity update)
=======
# System Table Schemas Enablement
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
module "system_table" {
  source = "./databricks_workspace/system_schema"
  providers = {
    databricks = databricks.created_workspace
  }
  depends_on = [module.uc_assignment]
}

<<<<<<< HEAD
<<<<<<< HEAD
# Create Create Cluster
=======
// Create Create Cluster
>>>>>>> b3e4c6f (aws simplicity update)
=======
# Create Create Cluster
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
module "cluster_configuration" {
  source = "./databricks_workspace/classic_cluster"
  providers = {
    databricks = databricks.created_workspace
  }

  resource_prefix = var.resource_prefix
<<<<<<< HEAD

  depends_on = [
    module.databricks_mws_workspace, module.vpc_endpoints
  ]
}

# Restrictive DBFS bucket policy
<<<<<<< HEAD
module "restrictive_root_bucket" {
  source = "./databricks_workspace/restrictive_root_bucket"
  providers = {
    aws = aws
  }

<<<<<<< HEAD
  databricks_account_id = var.databricks_account_id
  workspace_id          = module.databricks_mws_workspace.workspace_id
  region_name           = var.region_name
  root_s3_bucket        = "${var.resource_prefix}-workspace-root-storage"

  depends_on = [module.databricks_mws_workspace]
=======
  alert_emails = [var.user_workspace_admin]
=======
>>>>>>> b3e4c6f (aws simplicity update)

  depends_on = [
    module.databricks_mws_workspace, module.vpc_endpoints
  ]
<<<<<<< HEAD
>>>>>>> 101e277 (Adding workspace dependency for databricks_workspace.tf)
}
=======
}

// Restrictive DBFS bucket policy
=======
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
module "restrictive_root_bucket" {
  source = "./databricks_workspace/restrictive_root_bucket"
  providers = {
    aws = aws
  }

  databricks_account_id = var.databricks_account_id
  workspace_id          = module.databricks_mws_workspace.workspace_id
  region_name           = var.region_name
  root_s3_bucket        = "${var.resource_prefix}-workspace-root-storage"

  depends_on = [module.databricks_mws_workspace]
<<<<<<< HEAD
}

>>>>>>> b3e4c6f (aws simplicity update)
=======
}
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
