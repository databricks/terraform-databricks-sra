// EXPLANATION: All modules that reside at the account level

// Billable Usage and Audit Logs
module "log_delivery" {
  source = "./databricks_account/logging_configuration"
  count  = var.enable_logging_boolean ? 1 : 0
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
}


// Create Unity Catalog
module "uc_init" {
  count  = var.metastore_id == null ? 1 : 0
  source = "./databricks_account/uc_init"
  providers = {
    databricks = databricks.mws
  }

  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
  region                = var.region
  ucname                = var.ucname
}

// Unity Catalog Assignment
module "uc_assignment" {
  source = "./databricks_account/uc_assignment"
  providers = {
    databricks = databricks.mws
  }

  metastore_id = var.metastore_id != null ? var.metastore_id : module.uc_init[0].metastore_id
  workspace_id = module.databricks_mws_workspace.workspace_id
  depends_on = [
    module.databricks_mws_workspace
  ]
}


// Create Databricks Workspace
module "databricks_mws_workspace" {
  source = "./databricks_account/workspace"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id       = var.databricks_account_id
  resource_prefix             = var.resource_prefix
  security_group_ids          = [aws_security_group.sg.id]
  subnet_ids                  = module.vpc.private_subnets
  vpc_id                      = module.vpc.vpc_id
  cross_account_role_arn      = aws_iam_role.cross_account_role.arn
  bucket_name                 = aws_s3_bucket.root_storage_bucket.id
  region                      = var.region
  backend_rest                = aws_vpc_endpoint.backend_rest.id
  backend_relay               = aws_vpc_endpoint.backend_relay.id
  managed_storage_key         = aws_kms_key.managed_storage.arn
  workspace_storage_key       = aws_kms_key.workspace_storage.arn
  managed_storage_key_alias   = aws_kms_alias.managed_storage_key_alias.name
  workspace_storage_key_alias = aws_kms_alias.workspace_storage_key_alias.name
}