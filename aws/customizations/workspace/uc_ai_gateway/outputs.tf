output "mcp_service_name" {
  description = "Resource name of the UC AI Gateway MCP service, or null when disabled."
  value       = var.mcp_service == null ? null : databricks_ai_gateway_mcp_service.this[0].name
}

output "model_provider_service_name" {
  description = "Resource name of the UC AI Gateway Bedrock provider service, or null when disabled."
  value       = var.bedrock_provider_service == null ? null : databricks_ai_gateway_model_provider_service.bedrock[0].name
}

output "model_service_name" {
  description = "Resource name of the UC AI Gateway model service, or null when disabled."
  value       = var.model_service == null ? null : databricks_ai_gateway_model_service.this[0].name
}
