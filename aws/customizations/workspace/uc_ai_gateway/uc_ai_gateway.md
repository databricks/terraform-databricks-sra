### Unity Catalog AI Gateway

This Public Beta customization creates optional Unity Catalog AI Gateway securables:

- An AWS Bedrock model-provider service authenticated through an existing Unity Catalog service credential.
- A model service that routes requests to configured Bedrock targets.
- An MCP service backed by an existing Unity Catalog connection.

The customization intentionally does not accept inline cloud access keys or third-party API keys because Terraform would retain those values in state.

### Prerequisites

- Databricks Terraform provider 1.124.0 or later.
- An existing Unity Catalog catalog and schema.
- For Bedrock, an existing Unity Catalog service credential authorized to invoke the selected models.
- For MCP, an existing Unity Catalog connection to the MCP server.

### Add the customization to SRA

1. Copy the `uc_ai_gateway` folder into `aws/tf/modules/databricks_workspace/`.
2. Add a module block to `aws/tf/main.tf`:

```hcl
module "uc_ai_gateway" {
  source = "./modules/databricks_workspace/uc_ai_gateway"

  providers = {
    databricks = databricks.created_workspace
  }

  bedrock_provider_service = {
    id                      = "bedrock-provider"
    region                  = var.region
    service_credential_name = "bedrock-service-credential"
    targets = [{
      model            = "anthropic.claude-sonnet-4-5-20250929-v1:0"
      native_api_types = ["openai/v1/chat/completions"]
    }]
  }
  catalog_name = "example_catalog"
  model_service = {
    id = "governed-chat"
    destinations = [{
      model              = "anthropic.claude-sonnet-4-5-20250929-v1:0"
      name               = "claude-sonnet"
      native_api_types   = ["openai/v1/chat/completions"]
      traffic_percentage = 100
    }]
    rate_limits = [{
      key            = "RATE_LIMIT_KEY_SERVICE"
      renewal_period = "RATE_LIMIT_RENEWAL_PERIOD_MINUTE"
      requests       = 60
    }]
  }
  owner       = var.admin_user
  schema_name = "ai_gateway"
}
```

3. Run `terraform init -upgrade` so the lock file resolves provider 1.124.0 or later.
4. Run `terraform validate` and review the plan carefully before applying this Public Beta customization.

### MCP example

```hcl
mcp_service = {
  id                     = "governed-tools"
  source_connection_name = "connections/example-mcp-connection"
  include_tool_selectors = ["read_*"]
  rate_limits = [{
    key            = "RATE_LIMIT_KEY_USER_DEFAULT"
    renewal_period = "RATE_LIMIT_RENEWAL_PERIOD_MINUTE"
    requests       = 30
  }]
}
```

The provider resources and API are Public Beta. Keep this customization opt-in until Databricks promotes the feature and its Terraform state behavior has proven stable.
