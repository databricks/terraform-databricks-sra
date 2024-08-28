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
}

variable "compliance_security_profile_egress_ports" {
  type        = bool
  description = "Add 2443 to security group configuration or nitro instance"
  nullable    = false
}

variable "custom_private_subnet_ids" {
  type        = list(string)
  description = "List of custom private subnet IDs"
}

variable "custom_relay_vpce_id" {
  type        = string
  description = "Custom Relay VPC Endpoint ID"
}

variable "custom_sg_id" {
  type        = string
  description = "Custom security group ID"
}

variable "custom_vpc_id" {
  type        = string
  description = "Custom VPC ID"
}

variable "custom_workspace_vpce_id" {
  type        = string
  description = "Custom Workspace VPC Endpoint ID"
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "enable_admin_configs_boolean" {
  type        = bool
  description = "Enable workspace configs"
  nullable    = false
}

variable "enable_audit_log_alerting" {
  description = "Flag to audit log alerting."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_cluster_boolean" {
  description = "Flag to enable cluster."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_ip_boolean" {
  description = "Flag to enable IP-related configurations."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_logging_boolean" {
  description = "Flag to enable logging."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_read_only_external_location_boolean" {
  description = "Flag to enable read only external location"
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_restrictive_kinesis_endpoint_boolean" {
  type        = bool
  description = "Enable restrictive Kinesis endpoint boolean flag"
  default     = false
}

variable "enable_restrictive_root_bucket_boolean" {
  description = "Flag to enable restrictive root bucket settings."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_restrictive_s3_endpoint_boolean" {
  type        = bool
  description = "Enable restrictive S3 endpoint boolean flag"
  default     = false
}

variable "enable_restrictive_sts_endpoint_boolean" {
  type        = bool
  description = "Enable restrictive STS endpoint boolean flag"
  default     = false
}

variable "enable_sat_boolean" {
  description = "Flag for a specific SAT (Service Access Token) configuration."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_system_tables_schema_boolean" {
  description = "Flag for enabling public preview system schema access"
  type        = bool
  sensitive   = true
  default     = false
}

variable "firewall_allow_list" {
  description = "List of allowed firewall rules."
  type        = list(string)
}

variable "firewall_subnets_cidr" {
  description = "CIDR blocks for firewall subnets."
  type        = list(string)
}

variable "hms_fqdn" {
  type = map(string)
  default = {
    "civilian" = "discovery-search-rds-prod-dbdiscoverysearch-uus7j2cyyu1m.c40ji7ukhesx.us-gov-west-1.rds.amazonaws.com"
    "dod"      = "lineage-usgovwest1dod-prod.cpnejponioft.us-gov-west-1.rds.amazonaws.com"
  }
}

variable "ip_addresses" {
  description = "List of IP addresses to allow list."
  type        = list(string)
}

variable "metastore_exists" {
  description = "If a metastore exists"
  type        = bool
}

variable "operation_mode" {
  type        = string
  description = "The type of Operation Mode for the workspace network configuration."
  nullable    = false

  validation {
    condition     = contains(["sandbox", "firewall", "custom", "isolated"], var.operation_mode)
    error_message = "Invalid operation mode. Allowed values are: sandbox, firewall, custom, isolated."
  }
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
}

variable "privatelink_subnets_cidr" {
  description = "CIDR blocks for private link subnets."
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "read_only_data_bucket" {
  description = "S3 bucket for data storage."
  type        = string
}

variable "read_only_external_location_admin" {
  description = "User to grant external location admin."
  type        = string
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "scc_relay" {
  type = map(string)
  default = {
    "civilian" = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05f27abef1a1a3faa"
    "dod"      = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-08fddf710780b2a54"
  }
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
}

variable "user_workspace_admin" {
  description = "User to grant admin workspace access."
  type        = string
  nullable    = false
}

variable "user_workspace_catalog_admin" {
  description = "Admin for the workspace catalog"
  type        = string
}

variable "vpc_cidr_range" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "workspace" {
  type = map(string)
  default = {
    "civilian" = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-0f25e28401cbc9418"
    "dod"      = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05c210a2feea23ad7"
  }
}

variable "workspace_admin_service_principal_name" {
  description = "Service principal name"
  type        = string
}

// AWS Gov Only Variables
variable "databricks_gov_shard" {
  description = "Gov Shard civilian or dod"
  type        = string
}

variable "databricks_prod_aws_account_id" {
  description = "Databricks Prod AWS Account Id"
  type = map(string)
}

variable "log_delivery_role_name" {
  description = "Log Delivery Role Name"
  type = map(string)
}

variable "uc_master_role_id" {
  description = "UC Master Role ID"
  type = map(string)
}

