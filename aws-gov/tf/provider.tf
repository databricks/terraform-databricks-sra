terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
<<<<<<< HEAD
<<<<<<< HEAD
      version = "1.54.0"
=======
      version = " 1.54.0"
>>>>>>> c1185b0 (aws gov simplicity update)
=======
      version = "1.54.0"
>>>>>>> fc4eee5 ([aws-gov] fix(aws-gov) update naming convention of modules, update test, add required terraform provider)
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
  required_version = "~>1.0"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Resource = var.resource_prefix
    }
  }
}

provider "databricks" {
  alias         = "mws"
  host          = var.account_console[var.databricks_gov_shard]
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}