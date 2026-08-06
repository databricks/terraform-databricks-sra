locals {
  bedrock_provider_service_name = one(databricks_ai_gateway_model_provider_service.bedrock[*].name)
  parent                        = "schemas/${var.catalog_name}.${var.schema_name}"
}

resource "databricks_ai_gateway_model_provider_service" "bedrock" {
  count = var.bedrock_provider_service == null ? 0 : 1

  model_provider_service_id = var.bedrock_provider_service.id
  parent                    = local.parent
  comment                   = var.bedrock_provider_service.comment
  owner                     = var.owner

  config = {
    allow_all_targets = var.bedrock_provider_service.allow_all_targets
    amazon_bedrock = {
      direct = {
        region = var.bedrock_provider_service.region
        service_credential = {
          name = "credentials/${var.bedrock_provider_service.service_credential_name}"
        }
      }
    }
    provider_type = "EXTERNAL_MODEL_PROVIDER_TYPE_AMAZON_BEDROCK"
    rate_limits   = var.bedrock_provider_service.rate_limits
    targets       = var.bedrock_provider_service.targets
  }

  lifecycle {
    precondition {
      condition     = var.bedrock_provider_service.allow_all_targets || length(var.bedrock_provider_service.targets) > 0
      error_message = "bedrock_provider_service.targets must contain at least one target unless allow_all_targets is true."
    }
  }
}

resource "databricks_ai_gateway_model_service" "this" {
  count = var.model_service == null ? 0 : 1

  model_service_id = var.model_service.id
  parent           = local.parent
  comment          = var.model_service.comment
  owner            = var.owner

  config = {
    rate_limits = var.model_service.rate_limits
    routing = {
      destinations = [
        for destination in var.model_service.destinations : {
          destination_type   = "DESTINATION_TYPE_EXTERNAL_FOUNDATION_MODEL"
          name               = destination.name
          traffic_percentage = destination.traffic_percentage
          external_model_config = {
            model_provider_service = local.bedrock_provider_service_name
            target = {
              model            = destination.model
              native_api_types = destination.native_api_types
            }
          }
        }
      ]
      traffic_splitting = {}
    }
  }

  lifecycle {
    precondition {
      condition     = var.bedrock_provider_service != null
      error_message = "bedrock_provider_service must be configured when model_service is enabled."
    }


    precondition {
      condition     = length(var.model_service.destinations) >= 1 && length(var.model_service.destinations) <= 10
      error_message = "model_service.destinations must contain between one and ten destinations."
    }

    precondition {
      condition     = sum(var.model_service.destinations[*].traffic_percentage) == 100
      error_message = "model_service destination traffic percentages must total 100."
    }

    precondition {
      condition = try(
        var.bedrock_provider_service.allow_all_targets || alltrue([
          for destination in var.model_service.destinations : contains(var.bedrock_provider_service.targets[*].model, destination.model)
        ]),
        false,
      )
      error_message = "Every model_service destination must reference a declared Bedrock target unless allow_all_targets is true."
    }
  }
}

resource "databricks_ai_gateway_mcp_service" "this" {
  count = var.mcp_service == null ? 0 : 1

  mcp_service_id = var.mcp_service.id
  parent         = local.parent
  comment        = var.mcp_service.comment
  owner          = var.owner

  config = {
    include_tool_selectors = var.mcp_service.include_tool_selectors
    rate_limits            = var.mcp_service.rate_limits
    source_connection = {
      name = var.mcp_service.source_connection_name
    }
  }
}
