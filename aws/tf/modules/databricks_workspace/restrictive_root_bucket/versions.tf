terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
  }
  required_version = ">= 1.9, < 2.0"
}