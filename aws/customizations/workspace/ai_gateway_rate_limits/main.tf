// Terraform Documentation: 
// Data Source: https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/serving_endpoints
// API Reference: https://docs.databricks.com/api/workspace/servingendpoints/putaigateway

# Get all serving endpoints in the workspace
data "databricks_serving_endpoints" "all" {
}

# Get current workspace configuration for API calls
data "databricks_current_config" "this" {
}

# Configure AI Gateway rate limits using the Databricks API
# This uses curl with service principal OAuth authentication
# Requires DATABRICKS_CLIENT_ID and DATABRICKS_CLIENT_SECRET environment variables
resource "null_resource" "ai_gateway_rate_limits" {
  for_each = { for endpoint in data.databricks_serving_endpoints.all.endpoints : endpoint.name => endpoint }

  triggers = {
    endpoint_name = each.value.name
    # Re-run if the endpoint configuration changes
    endpoint_hash = sha256(jsonencode(each.value))
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Get OAuth token using service principal credentials
      TOKEN=$(curl -s -X POST "${data.databricks_current_config.this.host}/oidc/v1/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -u "$${DATABRICKS_CLIENT_ID:-$${ARM_CLIENT_ID}}:$${DATABRICKS_CLIENT_SECRET:-$${ARM_CLIENT_SECRET}}" \
        -d "grant_type=client_credentials&scope=all-apis" | jq -r '.access_token')
      
      # Configure AI Gateway rate limits
      curl -X PUT "${data.databricks_current_config.this.host}/api/2.0/serving-endpoints/${each.value.name}/ai-gateway" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "rate_limits": [
            {
              "key": "endpoint",
              "calls": 0,
              "renewal_period": "minute"
            }
          ]
        }'
    EOT
  }
}
