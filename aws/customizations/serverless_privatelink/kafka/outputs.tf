output "broker_nlb_ports" {
  description = "Map of broker name to the NLB port it is advertised on. Configure each broker's advertised.listeners to use the endpoint's private DNS name and this port."
  value       = { for name, b in local.brokers_by_name : name => b.nlb_port }
}

output "nlb_arn" {
  description = "ARN of the internal Network Load Balancer fronting the Kafka brokers."
  value       = aws_lb.kafka.arn
}

output "nlb_dns_name" {
  description = "DNS name of the internal Network Load Balancer."
  value       = aws_lb.kafka.dns_name
}

output "vpc_endpoint_service_id" {
  description = "ID of the VPC endpoint service."
  value       = aws_vpc_endpoint_service.kafka.id
}

output "vpc_endpoint_service_name" {
  description = "Name of the VPC endpoint service (com.amazonaws.vpce.<region>.vpce-svc-xxxx). Add this to the SRA serverless_private_endpoint_rules variable to register it with the Databricks NCC."
  value       = aws_vpc_endpoint_service.kafka.service_name
}
