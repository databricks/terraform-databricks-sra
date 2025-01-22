data "aws_availability_zones" "available" {
  state = "available"
}

variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string
}

variable "aws_account_id" {
  description = "ID of the AWS account."
  type        = string
}

variable "client_id" {
  description = "Client ID for authentication."
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Secret key for the client ID."
  type        = string
  sensitive   = true
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region code. (e.g. us-east-1)"
  type        = string
  validation {
    condition     = contains(["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-1", "us-east-2", "us-west-2"], var.region)
    error_message = "Valid values for var: region are (ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1, us-east-2, us-west-2)."
  }
}

variable "region_name" {
  description = "Name of the AWS region. (e.g. nvirginia)"
  type        = map(string)
  default = {
    "ap-northeast-1" = "tokyo"
    "ap-northeast-2" = "seoul"
    "ap-south-1"     = "mumbai"
    "ap-southeast-1" = "singapore"
    "ap-southeast-2" = "sydney"
    "ca-central-1"   = "canada"
    "eu-central-1"   = "frankfurt"
    "eu-west-1"      = "ireland"
    "eu-west-2"      = "london"
    "eu-west-3"      = "paris"
    "sa-east-1"      = "saopaulo"
    "us-east-1"      = "nvirginia"
    "us-east-2"      = "ohio"
    "us-west-2"      = "oregon"
    #"us-west-1" = "oregon"
  }
}

variable "region_bucket_name" {
  description = "Name of the AWS region. (e.g. virginia)"
  type        = map(string)
  default = {
    "ap-northeast-1" = "tokyo"
    "ap-northeast-2" = "seoul"
    "ap-south-1"     = "mumbai"
    "ap-southeast-1" = "singapore"
    "ap-southeast-2" = "sydney"
    "ca-central-1"   = "montreal"
    "eu-central-1"   = "frankfurt"
    "eu-west-1"      = "ireland"
    "eu-west-2"      = "london"
    "eu-west-3"      = "paris"
    "sa-east-1"      = "saopaulo"
    "us-east-1"      = "virginia"
    "us-east-2"      = "ohio"
    "us-west-2"      = "oregon"
    # "us-west-1"      = "oregon"
  }
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Invalid resource prefix. Allowed characters are a-z, 0-9, -"
  }
}