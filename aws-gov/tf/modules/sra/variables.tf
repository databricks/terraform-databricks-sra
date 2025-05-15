variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string
}

variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of AWS availability zones."
  type        = list(string)
}

variable "aws_account_id" {
  description = "ID of the AWS account."
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Client ID for Databricks authentication."
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Secret key for the Databricks client ID."
  type        = string
  sensitive   = true
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
  default     = null
}

variable "custom_private_subnet_ids" {
  description = "List of custom private subnet IDs"
  type        = list(string)
  default     = null
}

variable "custom_relay_vpce_id" {
  description = "Custom Relay VPC Endpoint ID"
  type        = string
  default     = null
}

variable "custom_sg_id" {
  description = "Custom security group ID"
  type        = string
  default     = null
}

variable "custom_vpc_id" {
  description = "Custom VPC ID"
  type        = string
  default     = null
}

variable "custom_workspace_vpce_id" {
  description = "Custom Workspace VPC Endpoint ID"
  type        = string
  default     = null
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "deployment_name" {
  description = "Deployment name for the workspace. Must first be enabled by a Databricks representative."
  type        = string
  nullable    = true
}

variable "enable_security_analysis_tool" {
  description = "Flag to enable the security analysis tool."
  type        = bool
  sensitive   = true
  default     = false
}

variable "metastore_exists" {
  description = "If a metastore exists"
  type        = bool
}

variable "network_configuration" {
  description = "The type of network set-up for the workspace network configuration."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["custom", "isolated"], var.network_configuration)
    error_message = "Invalid network configuration. Allowed values are: custom, isolated."
  }
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  nullable    = true
}

variable "privatelink_subnets_cidr" {
  description = "CIDR blocks for private link subnets."
  type        = list(string)
  nullable    = true
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "region_bucket_name" {
  description = "Name of the AWS region for buckets."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "scc_relay" {
  description = "Secure Cluster Connectivity Relay PrivateLink Endpoint Map"
  type = map(string)
  default = {
    "civilian" = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05f27abef1a1a3faa"
    "dod"      = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05c210a2feea23ad7"
  }
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
}

variable "vpc_cidr_range" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "workspace" {
  description = "Workspace API PrivateLink Endpoint Map"
  type = map(string)
  default = {
    "civilian" = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-0f25e28401cbc9418"
    "dod"      = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-08fddf710780b2a54"
  }
}

// AWS Gov Only Variables
variable "databricks_gov_shard" {
  description = "Gov Shard civilian or dod"
  type        = string
}

variable "databricks_prod_aws_account_id" {
  description = "Databricks Prod AWS Account Id"
  type = map(string)
  default = {
    "civilian" = "044793339203"
    "dod"      = "170661010020"
  }
}

variable "log_delivery_role_name" {
  description = "Log Delivery Role Name"
  type = map(string)
  default = {
    "civilian" = "role/SaasUsageDeliveryRole-prod-aws-gov-IAMRole-L4QM0RCHYQ1G"
    "dod"      = "role/SaasUsageDeliveryRole-prod-aws-gov-dod-IAMRole-1DMEHBYR8VC5P"
  }
}

variable "uc_master_role_id" {
  description = "UC Master Role ID"
  type = map(string)
  default = {
    "civilian" = "1QRFA8SGY15OJ"
    "dod"      = "1DI6DL6ZP26AS"
  }
}
