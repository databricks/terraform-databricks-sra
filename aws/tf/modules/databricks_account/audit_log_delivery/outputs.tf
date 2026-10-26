output "bucket_name" {
  description = "Name of the audit log delivery bucket."
  value       = aws_s3_bucket.log_delivery.bucket
}
