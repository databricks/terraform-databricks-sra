# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_log_delivery

# S3 Bucket
resource "aws_s3_bucket" "log_delivery" {
  bucket        = "${var.resource_prefix}-audit-log-delivery"
  force_destroy = true
  tags = {
    Name    = "${var.resource_prefix}-audit-log-delivery"
    Project = var.resource_prefix
  }
}

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "log_delivery" {
  bucket                  = aws_s3_bucket.log_delivery.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.log_delivery]
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "log_delivery_versioning" {
  bucket = aws_s3_bucket.log_delivery.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Bucket Policy Data Source
data "databricks_aws_bucket_policy" "log_delivery" {
  full_access_role = aws_iam_role.log_delivery.arn
  aws_partition    = var.aws_assume_partition
  bucket           = aws_s3_bucket.log_delivery.bucket
}

# Bucket Policy
resource "aws_s3_bucket_policy" "log_delivery" {
  bucket = aws_s3_bucket.log_delivery.id
  policy = data.databricks_aws_bucket_policy.log_delivery.json
}

# Assume Role
data "databricks_aws_assume_role_policy" "log_delivery" {
  external_id      = var.databricks_account_id
  for_log_delivery = true
  aws_partition    = var.aws_assume_partition
}

# IAM Role
resource "aws_iam_role" "log_delivery" {
  name               = "${var.resource_prefix}-audit-log-delivery-role"
  description        = "(${var.resource_prefix}) Audit Log Delivery role"
  assume_role_policy = data.databricks_aws_assume_role_policy.log_delivery.json
  tags = {
    Name    = "${var.resource_prefix}-audit-log-delivery-role"
    Project = var.resource_prefix
  }
}

# Wait for Role
resource "time_sleep" "wait" {
  depends_on = [
    aws_iam_role.log_delivery
  ]
  create_duration = "10s"
}

# Log Credential
resource "databricks_mws_credentials" "log_writer" {
  credentials_name = "${var.resource_prefix}-audit-log-delivery-credential"
  role_arn         = aws_iam_role.log_delivery.arn
  depends_on = [
    time_sleep.wait
  ]
}

# Log Storage Configuration
resource "databricks_mws_storage_configurations" "log_bucket" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = "${var.resource_prefix}-audit-log-delivery-storage"
  bucket_name                = aws_s3_bucket.log_delivery.bucket
}

# Log Delivery
resource "databricks_mws_log_delivery" "audit_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "audit-logs"
  config_name              = "Audit Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
}