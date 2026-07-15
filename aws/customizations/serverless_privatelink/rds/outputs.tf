output "nlb_arn" {
  description = "ARN of the internal Network Load Balancer fronting the RDS endpoint."
  value       = aws_lb.rds.arn
}

output "nlb_dns_name" {
  description = "DNS name of the internal Network Load Balancer."
  value       = aws_lb.rds.dns_name
}

output "nlb_port" {
  description = "Port the NLB listens on and advertises to serverless compute. Serverless clients connect to the RDS instance on this port through the endpoint."
  value       = local.nlb_port
}

output "vpc_endpoint_service_id" {
  description = "ID of the VPC endpoint service."
  value       = aws_vpc_endpoint_service.rds.id
}

output "vpc_endpoint_service_name" {
  description = "Name of the VPC endpoint service (com.amazonaws.vpce.<region>.vpce-svc-xxxx). Add this to the SRA serverless_private_endpoint_rules variable to register it with the Databricks NCC."
  value       = aws_vpc_endpoint_service.rds.service_name
}
