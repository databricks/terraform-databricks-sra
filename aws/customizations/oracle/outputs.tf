output "connection_name" {
  description = "Name of the Unity Catalog connection to the Oracle database. Use it when creating a Lakeflow Connect Oracle ingestion pipeline."
  value       = databricks_connection.oracle.name
}

output "foreign_catalog_name" {
  description = "Name of the Unity Catalog foreign catalog over the Oracle connection."
  value       = databricks_catalog.oracle.name
}

output "nlb_arn" {
  description = "ARN of the internal Network Load Balancer fronting the Oracle database."
  value       = aws_lb.oracle.arn
}

output "nlb_dns_name" {
  description = "DNS name of the internal Network Load Balancer."
  value       = aws_lb.oracle.dns_name
}

output "nlb_port" {
  description = "Port the NLB listens on and advertises to serverless compute. Serverless clients connect to the Oracle database on this port through the endpoint."
  value       = local.nlb_port
}

output "private_endpoint_rule_id" {
  description = "ID of the NCC private endpoint rule pointing at the VPC endpoint service."
  value       = databricks_mws_ncc_private_endpoint_rule.oracle.rule_id
}

output "vpc_endpoint_service_id" {
  description = "ID of the VPC endpoint service."
  value       = aws_vpc_endpoint_service.oracle.id
}

output "vpc_endpoint_service_name" {
  description = "Name of the VPC endpoint service (com.amazonaws.vpce.<region>.vpce-svc-xxxx) registered with the NCC private endpoint rule."
  value       = aws_vpc_endpoint_service.oracle.service_name
}
