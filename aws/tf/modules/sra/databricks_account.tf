# EXPLANATION: All modules that reside at the account level

<<<<<<< HEAD
<<<<<<< HEAD
# Create Unity Catalog Metastore - No Root Storage
=======

// Create Unity Catalog Metastore - No Root Storage
>>>>>>> b3e4c6f (aws simplicity update)
=======
# Create Unity Catalog Metastore - No Root Storage
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
module "uc_init" {
  source = "./databricks_account/uc_init"
  providers = {
    databricks = databricks.mws
  }

  resource_prefix  = var.resource_prefix
  region           = var.region
  metastore_exists = var.metastore_exists
}

# Unity Catalog Assignment
module "uc_assignment" {
  source = "./databricks_account/uc_assignment"
  providers = {
    databricks = databricks.mws
  }

  metastore_id = module.uc_init.metastore_id
  workspace_id = module.databricks_mws_workspace.workspace_id
  depends_on   = [module.databricks_mws_workspace, module.uc_init]
}

# Create Databricks Workspace
module "databricks_mws_workspace" {
  source = "./databricks_account/workspace"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id       = var.databricks_account_id
  resource_prefix             = var.resource_prefix
  security_group_ids          = var.custom_sg_id != null ? [var.custom_sg_id] : [aws_security_group.sg[0].id]
  subnet_ids                  = var.custom_private_subnet_ids != null ? var.custom_private_subnet_ids : module.vpc[0].private_subnets
  vpc_id                      = var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc[0].vpc_id
  cross_account_role_arn      = aws_iam_role.cross_account_role.arn
  bucket_name                 = aws_s3_bucket.root_storage_bucket.id
  region                      = var.region
  backend_rest                = var.custom_workspace_vpce_id != null ? var.custom_workspace_vpce_id : aws_vpc_endpoint.backend_rest[0].id
  backend_relay               = var.custom_relay_vpce_id != null ? var.custom_relay_vpce_id : aws_vpc_endpoint.backend_relay[0].id
  managed_storage_key         = aws_kms_key.managed_storage.arn
  workspace_storage_key       = aws_kms_key.workspace_storage.arn
  managed_storage_key_alias   = aws_kms_alias.managed_storage_key_alias.name
  workspace_storage_key_alias = aws_kms_alias.workspace_storage_key_alias.name
  deployment_name             = var.deployment_name
}

# User Workspace Assignment (Admin)
module "user_assignment" {
  source = "./databricks_account/user_assignment"
  providers = {
    databricks = databricks.mws
  }

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
  workspace_id     = module.databricks_mws_workspace.workspace_id
  workspace_access = var.admin_user
  depends_on       = [module.uc_assignment, module.databricks_mws_workspace]
}

# Audit log delivery
module "log_delivery" {
<<<<<<< HEAD
  count = var.audit_log_delivery_exists ? 0 : 1
=======
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
  source = "./databricks_account/audit_log_delivery"
  providers = {
    databricks = databricks.mws
  }

<<<<<<< HEAD
<<<<<<< HEAD
  audit_log_delivery_exists = var.audit_log_delivery_exists
  databricks_account_id     = var.databricks_account_id
  resource_prefix           = var.resource_prefix
=======
  created_workspace_id = module.databricks_mws_workspace.workspace_id
  workspace_access     = var.admin_user
  depends_on           = [module.uc_assignment, module.databricks_mws_workspace]
>>>>>>> b3e4c6f (aws simplicity update)
=======
  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
=======
  audit_log_delivery_exists = var.audit_log_delivery_exists
  databricks_account_id     = var.databricks_account_id
  resource_prefix           = var.resource_prefix
>>>>>>> 0ef66cd ([AWS, AWS-GOV] Added Boolean for Audit Log Delivery)
}