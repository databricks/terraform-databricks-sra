// Data Source: https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/serving_endpoints
// API Reference: https://docs.databricks.com/api/workspace/servingendpoints/putaigateway

data "databricks_serving_endpoints" "all" {}

data "databricks_current_config" "this" {}

locals {
  endpoints = {
    for endpoint in data.databricks_serving_endpoints.all.endpoints : endpoint.name => endpoint
    if !contains(var.excluded_endpoint_names, endpoint.name)
  }

  ai_gateway_config = jsonencode({
    rate_limits = [{
      key            = "endpoint"
      calls          = var.endpoint_rate_limit_calls
      renewal_period = var.endpoint_rate_limit_renewal_period
    }]
  })
}

resource "terraform_data" "configuration" {
  input = {
    rate_limit_calls = var.endpoint_rate_limit_calls
    renewal_period   = var.endpoint_rate_limit_renewal_period
  }

  lifecycle {
    precondition {
      condition     = var.endpoint_rate_limit_calls > 0 || var.allow_zero_calls
      error_message = "endpoint_rate_limit_calls = 0 blocks all requests. Set allow_zero_calls = true to confirm that intentional shutdown."
    }
  }
}

# Configure AI Gateway rate limits using the Databricks CLI. Authentication credentials are inherited
# from the Terraform process; DATABRICKS_HOST pins CLI requests to the provider's workspace.
# NOTE: The Databricks CLI is used because Terraform can only manage the ai_gateway block on serving
# endpoints it created; this customization applies rate limits to all non-excluded workspace endpoints.
resource "terraform_data" "ai_gateway_rate_limits" {
  for_each = local.endpoints

  depends_on = [terraform_data.configuration]

  input = {
    endpoint_name    = each.value.name
    rate_limit_calls = var.endpoint_rate_limit_calls
    renewal_period   = var.endpoint_rate_limit_renewal_period
  }

  # Provisioners only execute during create/destroy. Force replacement whenever enforcement inputs change.
  triggers_replace = [
    local.ai_gateway_config,
    var.enforcement_revision,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      if ! command -v databricks >/dev/null 2>&1; then
        echo "Databricks CLI is required to configure AI Gateway rate limits." >&2
        exit 1
      fi
      databricks serving-endpoints put-ai-gateway "$DATABRICKS_ENDPOINT_NAME" --json "$DATABRICKS_AI_GATEWAY_CONFIG"
    EOT

    environment = {
      DATABRICKS_HOST              = data.databricks_current_config.this.host
      DATABRICKS_ENDPOINT_NAME     = each.value.name
      DATABRICKS_AI_GATEWAY_CONFIG = local.ai_gateway_config
    }
  }
}
