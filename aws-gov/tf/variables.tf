data "aws_availability_zones" "available" {
  state = "available"
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
  description = "Databricks only operates in AWS Gov West (us-gov-west-1)"
  default = "us-gov-west-1"
  validation {
    condition     = contains(["us-gov-west-1"], var.region)
    error_message = "Valid value for var: region is (us-gov-west-1)."
  }
}

variable "region_name" {
  description = "Name of the AWS region. (e.g. pendleton)"
  type        = map(string)
  default = {
    "civilian" = "pendleton"
    "dod" = "pendleton-dod"
  }
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

// AWS Gov Only Variables
variable "account_console" {
  type = map(string)
  default = {
    "civilian" = "https://accounts.cloud.databricks.us/"
    "dod"      = "https://accounts-dod.cloud.databricks.us/"
  }
}

variable "databricks_gov_shard" {
  description = "pick shard: civilian, dod"
  validation {
    condition     = contains(["civilian", "dod"], var.databricks_gov_shard)
    error_message = "Valid values for var: databricks_gov_shard are (civilian, dod)."
  }
}