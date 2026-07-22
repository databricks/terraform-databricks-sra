output "git_nlb_ports" {
  description = "Ports the NLB listens on and advertises to serverless compute. Serverless clients reach the Git server on these ports through the endpoint."
  value       = var.git_ports
}

output "nlb_arn" {
  description = "ARN of the internal Network Load Balancer fronting the Git server."
  value       = aws_lb.git.arn
}

output "nlb_dns_name" {
  description = "DNS name of the internal Network Load Balancer."
  value       = aws_lb.git.dns_name
}

output "vpc_endpoint_service_id" {
  description = "ID of the VPC endpoint service."
  value       = aws_vpc_endpoint_service.git.id
}

output "vpc_endpoint_service_name" {
  description = "Name of the VPC endpoint service (com.amazonaws.vpce.<region>.vpce-svc-xxxx). Add this to the SRA serverless_private_endpoint_rules variable to register it with the Databricks NCC."
  value       = aws_vpc_endpoint_service.git.service_name
}
