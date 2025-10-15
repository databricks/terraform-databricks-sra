output "catalog_bucket_name" {
  description = "Catalog bucket name."
  value       = aws_s3_bucket.unity_catalog_bucket.bucket
}

output "catalog_name" {
  description = "Name of the catalog created"
  value       = databricks_catalog.workspace_catalog.name
}
