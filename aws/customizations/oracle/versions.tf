# Standalone example. Authenticate the AWS provider using environment variables:
# https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
#   export AWS_ACCESS_KEY_ID=KEY_ID
#   export AWS_SECRET_ACCESS_KEY=SECRET_KEY
#   export AWS_SESSION_TOKEN=SESSION_TOKEN
#
# Authenticate the Databricks providers using environment variables (a service
# principal that is an account admin and a workspace admin):
# https://registry.terraform.io/providers/databricks/databricks/latest/docs#argument-reference
#   export DATABRICKS_CLIENT_ID=CLIENT_ID
#   export DATABRICKS_CLIENT_SECRET=CLIENT_SECRET

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.121, < 2.0"
    }
  }
  required_version = ">= 1.9, < 2.0"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Resource = var.resource_prefix
    }
  }
}

# Account-level provider: NCC private endpoint rule.
provider "databricks" {
  alias      = "account"
  host       = local.databricks_account_host
  account_id = var.databricks_account_id
}

# Workspace-level provider: Unity Catalog connection and foreign catalog.
provider "databricks" {
  alias      = "workspace"
  host       = var.databricks_workspace_host
  account_id = var.databricks_account_id
}
