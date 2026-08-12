output "managed_endpoint_names" {
  description = "Serving endpoint names subject to workspace-wide AI Gateway rate-limit enforcement."
  value       = sort(keys(terraform_data.ai_gateway_rate_limits))
}

output "excluded_endpoint_names" {
  description = "Serving endpoint names excluded from workspace-wide AI Gateway rate-limit enforcement."
  value       = sort(tolist(var.excluded_endpoint_names))
}
