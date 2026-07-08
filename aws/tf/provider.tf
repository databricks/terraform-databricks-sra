terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.121"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.76, <7.0"
    }
  }
  required_version = "~>1.3"
}

# Authenticate using environment variables: https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
# export AWS_ACCESS_KEY_ID=KEY_ID
# export AWS_SECRET_ACCESS_KEY=SECRET_KEY
# export AWS_SESSION_TOKEN=SESSION_TOKEN

# Serverless-only deployments (compute_mode = "SERVERLESS") create no AWS resources and require no AWS
# account or credentials. The placeholder credentials and skip flags below apply only in that mode and
# prevent the provider from attempting credential resolution; in HYBRID mode they are unset and the
# normal AWS credential chain is used.
provider "aws" {
  region                      = var.region
  access_key                  = local.is_serverless ? "serverless-placeholder" : null
  secret_key                  = local.is_serverless ? "serverless-placeholder" : null
  skip_credentials_validation = local.is_serverless
  skip_requesting_account_id  = local.is_serverless
  skip_metadata_api_check     = local.is_serverless
  default_tags {
    tags = {
      Resource = var.resource_prefix
    }
  }
}

# Authenticate using environment variables: https://registry.terraform.io/providers/databricks/databricks/latest/docs#argument-reference
# export DATABRICKS_CLIENT_ID=CLIENT_ID
# export DATABRICKS_CLIENT_SECRET=CLIENT_SECRET

provider "databricks" {
  alias      = "mws"
  host       = local.computed_databricks_provider_host
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias      = "created_workspace"
  host       = module.databricks_mws_workspace.workspace_url
  account_id = var.databricks_account_id
}
