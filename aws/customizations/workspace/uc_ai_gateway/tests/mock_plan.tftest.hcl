mock_provider "databricks" {}

variables {
  bedrock_provider_service = {
    id                      = "bedrock-provider"
    region                  = "us-west-2"
    service_credential_name = "bedrock-service-credential"
    targets = [{
      model            = "anthropic.claude-sonnet-4-5-20250929-v1:0"
      native_api_types = ["openai/v1/chat/completions"]
    }]
  }
  catalog_name = "example_catalog"
  mcp_service = {
    id                     = "governed-tools"
    source_connection_name = "connections/example-mcp-connection"
  }
  model_service = {
    id = "governed-chat"
    destinations = [{
      model              = "anthropic.claude-sonnet-4-5-20250929-v1:0"
      name               = "claude-sonnet"
      native_api_types   = ["openai/v1/chat/completions"]
      traffic_percentage = 100
    }]
  }
  schema_name = "ai_gateway"
}

run "plan_valid_configuration" {
  command = plan
}
