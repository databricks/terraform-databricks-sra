output "catalog_bucket_name" {
  description = "Catalog bucket name. Null for serverless workspaces, which use Databricks default storage."
  value       = var.is_serverless ? null : aws_s3_bucket.unity_catalog_bucket[0].bucket
}

output "catalog_name" {
  description = "Name of the catalog created"
  value       = databricks_catalog.workspace_catalog.name
}
