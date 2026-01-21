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
resource "terraform_data" "ai_gateway_rate_limits" {
  for_each = { for endpoint in data.databricks_serving_endpoints.all.endpoints : endpoint.name => endpoint }

  input = {
    endpoint_name = each.value.name
    command       = "databricks serving-endpoints put-ai-gateway \"${each.value.name}\" --json '{\"rate_limits\": [{\"key\": \"endpoint\", \"calls\": 0, \"renewal_period\": \"minute\"}]}'"
    environment = {
      DATABRICKS_HOST = data.databricks_current_config.this.host
    }
  }

  provisioner "local-exec" {
    command     = self.input.command
    environment = self.input.environment
  }
}
