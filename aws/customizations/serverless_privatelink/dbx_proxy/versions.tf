# Standalone example. Authenticate the AWS provider using environment variables:
# https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
#   export AWS_ACCESS_KEY_ID=KEY_ID
#   export AWS_SECRET_ACCESS_KEY=SECRET_KEY
#   export AWS_SESSION_TOKEN=SESSION_TOKEN
#
# NOTE: The sourced dbx-proxy module (terraform/aws) declares its own aws, random, and cloudinit
# providers and configures the aws provider from var.region. This wrapper therefore does not declare
# a provider block of its own.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.76, <7.0"
    }
  }
  required_version = "~>1.3"
}
