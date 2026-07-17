output "nlb_arn" {
  description = "ARN of the internal Network Load Balancer fronting the S3 interface endpoint."
  value       = aws_lb.s3.arn
}

output "nlb_dns_name" {
  description = "DNS name of the internal Network Load Balancer."
  value       = aws_lb.s3.dns_name
}

output "s3_interface_endpoint_id" {
  description = "ID of the S3 interface VPC endpoint fronted by the NLB."
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_service_id" {
  description = "ID of the VPC endpoint service."
  value       = aws_vpc_endpoint_service.s3.id
}

output "vpc_endpoint_service_name" {
  description = "Name of the VPC endpoint service (com.amazonaws.vpce.<region>.vpce-svc-xxxx). Add this to the SRA serverless_private_endpoint_rules variable to register it with the Databricks NCC."
  value       = aws_vpc_endpoint_service.s3.service_name
}
