# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_log_delivery

# S3 Bucket
resource "aws_s3_bucket" "logdelivery" {
  count = var.audit_log_delivery_exists ? 0 : 1
  bucket        = "${var.resource_prefix}-log-delivery"
  force_destroy = true
  tags = {
    Name    = "${var.resource_prefix}-log-delivery"
    Project = var.resource_prefix
  }
}

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "logdelivery" {
  count = var.audit_log_delivery_exists ? 0 : 1
  bucket                  = aws_s3_bucket.logdelivery[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.logdelivery]
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "logdelivery_versioning" {
  count = var.audit_log_delivery_exists ? 0 : 1
  bucket = aws_s3_bucket.logdelivery[count.index].id
  versioning_configuration {
    status = "Disabled"
  }
}

# Bucket Policy Data Source
data "databricks_aws_bucket_policy" "logdelivery" {
  count = var.audit_log_delivery_exists ? 0 : 1
  full_access_role = aws_iam_role.logdelivery[count.index].arn
  bucket           = aws_s3_bucket.logdelivery[count.index].bucket
}

# Bucket Policy
resource "aws_s3_bucket_policy" "logdelivery" {
  count = var.audit_log_delivery_exists ? 0 : 1
  bucket = aws_s3_bucket.logdelivery[count.index].id
  policy = data.databricks_aws_bucket_policy.logdelivery[count.index].json
}

# Assume Role
data "databricks_aws_assume_role_policy" "logdelivery" {
  count = var.audit_log_delivery_exists ? 0 : 1
  external_id      = var.databricks_account_id
  for_log_delivery = true
}

# IAM Role
resource "aws_iam_role" "logdelivery" {
  count = var.audit_log_delivery_exists ? 0 : 1
  name               = "${var.resource_prefix}-log-delivery-role"
  description        = "(${var.resource_prefix}) UsageDelivery role"
  assume_role_policy = data.databricks_aws_assume_role_policy.logdelivery[count.index].json
  tags = {
    Name    = "${var.resource_prefix}-logdelivery"
    Project = var.resource_prefix
  }
}

# Wait for Role
resource "time_sleep" "wait" {
  count = var.audit_log_delivery_exists ? 0 : 1
  depends_on = [
    aws_iam_role.logdelivery[count.index]
  ]
  create_duration = "10s"
}

# Log Credential
resource "databricks_mws_credentials" "log_writer" {
  count = var.audit_log_delivery_exists ? 0 : 1
  credentials_name = "Usage Delivery"
  role_arn         = aws_iam_role.logdelivery[count.index].arn
  depends_on = [
    time_sleep.wait
  ]
}

# Log Storage Configuration
resource "databricks_mws_storage_configurations" "log_bucket" {
  count = var.audit_log_delivery_exists ? 0 : 1
  account_id                 = var.databricks_account_id
  storage_configuration_name = "Usage Logs"
  bucket_name                = aws_s3_bucket.logdelivery[count.index].bucket
}

# Log Delivery
resource "databricks_mws_log_delivery" "audit_logs" {
  count = var.audit_log_delivery_exists ? 0 : 1
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer[count.index].credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket[count.index].storage_configuration_id
  delivery_path_prefix     = "audit-logs"
  config_name              = "Audit Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
}