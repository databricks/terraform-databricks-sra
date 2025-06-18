output "catalog_bucket_name" {
  description = "Catalog bucket name."
  value       = aws_s3_bucket.unity_catalog_bucket.bucket
}