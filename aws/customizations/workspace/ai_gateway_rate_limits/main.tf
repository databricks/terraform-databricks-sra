// Terraform Documentation: 
// Data Source: https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/serving_endpoints
// API Reference: https://docs.databricks.com/api/workspace/servingendpoints/putaigateway

# Get all serving endpoints in the workspace
data "databricks_serving_endpoints" "all" {
}

# Get current workspace configuration
data "databricks_current_config" "this" {
}

# Configure AI Gateway rate limits using the Databricks CLI
# Authentication is inherited from the Databricks provider configuration via environment variables
# NOTE: The Databricks CLI is used because Terraform can only manage the ai_gateway block on serving
# endpoints it created; this customization applies rate limits to ALL endpoints in the workspace.
# The default endpoint_rate_limit_calls of 0 blocks all traffic to every endpoint.
resource "terraform_data" "ai_gateway_rate_limits" {
  for_each = { for endpoint in data.databricks_serving_endpoints.all.endpoints : endpoint.name => endpoint }

  input = {
    endpoint_name = each.value.name
    command       = "databricks serving-endpoints put-ai-gateway \"${each.value.name}\" --json '{\"rate_limits\": [{\"key\": \"endpoint\", \"calls\": ${var.endpoint_rate_limit_calls}, \"renewal_period\": \"${var.endpoint_rate_limit_renewal_period}\"}]}'"
    environment = {
      DATABRICKS_HOST = data.databricks_current_config.this.host
    }
  }

  provisioner "local-exec" {
    command     = self.input.command
    environment = self.input.environment
  }
}
