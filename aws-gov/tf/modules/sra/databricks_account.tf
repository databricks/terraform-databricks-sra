// EXPLANATION: All modules that reside at the account level

// Billable Usage and Audit Logs
module "log_delivery" {
  source = "./databricks_account/logging_configuration"
  count  = var.enable_logging_boolean ? 1 : 0
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id          = var.databricks_account_id
  resource_prefix                = var.resource_prefix
  databricks_gov_shard           = var.databricks_gov_shard
  databricks_prod_aws_account_id = var.databricks_prod_aws_account_id
  log_delivery_role_name         = var.log_delivery_role_name
}


// Create Unity Catalog Metastore - No Root Storage
module "uc_init" {
  source = "./databricks_account/uc_init"
  providers = {
    databricks = databricks.mws
  }

  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
  region                = var.region
  metastore_name        = join("", [var.resource_prefix, "-", var.region, "-", "uc"])
  metastore_exists      = var.metastore_exists
}

// Unity Catalog Assignment
module "uc_assignment" {
  source = "./databricks_account/uc_assignment"
  providers = {
    databricks = databricks.mws
  }

  metastore_id = module.uc_init.metastore_id
  region       = var.region
  workspace_id = module.databricks_mws_workspace.workspace_id
  depends_on   = [module.databricks_mws_workspace, module.uc_init]
}

// Create Databricks Workspace
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
}

// User Workspace Assignment (Admin)
module "user_assignment" {
  source = "./databricks_account/user_assignment"
  providers = {
    databricks = databricks.mws
  }

  created_workspace_id = module.databricks_mws_workspace.workspace_id
  workspace_access     = var.user_workspace_admin
  depends_on           = [module.uc_assignment, module.databricks_mws_workspace]
}