variable "availability_zones" {
  description = "List of AWS availability zones."
  type        = list(string)
}

variable "aws_account_id" {
  description = "ID of the AWS account."
  type        = string
  sensitive   = true
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
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

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "databricks_account_password" {
  description = "Password for the Databricks account."
  type        = string
  sensitive   = true
}

variable "databricks_account_username" {
  description = "Username for the Databricks account."
  type        = string
  sensitive   = true
}

variable "data_access_user" {
  description = "User to grant data access and workspace access."
  type        = string
}

variable "data_bucket" {
  description = "S3 bucket for data storage."
  type        = string
}

variable "dbfsname" {
  description = "Name for Databricks File System (DBFS)."
  type        = string
}

variable "enable_cluster_boolean" {
  description = "Flag to enable cluster."
  type        = bool
  sensitive   = true
}

variable "enable_firewall_boolean" {
  description = "Flag to enable firewall settings."
  type        = bool
  sensitive   = true
}

variable "enable_ip_boolean" {
  description = "Flag to enable IP-related configurations."
  type        = bool
  sensitive   = true
}

variable "enable_logging_boolean" {
  description = "Flag to enable logging."
  type        = bool
  sensitive   = true
}

variable "enable_restrictive_root_bucket_boolean" {
  description = "Flag to enable restrictive root bucket settings."
  type        = bool
  sensitive   = true
}

variable "enable_sat_boolean" {
  description = "Flag for a specific SAT (Service Access Token) configuration."
  type        = bool
  sensitive   = true
}

variable "firewall_allow_list" {
  description = "List of allowed firewall rules."
  type        = list(string)
}

variable "firewall_protocol_deny_list" {
  description = "Protocol list that the firewall should deny."
  type        = string
}

variable "firewall_subnets_cidr" {
  description = "CIDR blocks for firewall subnets."
  type        = list(string)
}

variable "ip_addresses" {
  description = "List of IP addresses to allow list."
  type        = list(string)
}

variable "metastore_id" {
  description = "ID for the Unity Catalog metastore."
  type        = string
  sensitive   = true
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

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "relay_vpce_service" {
  description = "VPCE service for the secure cluster connectivity relay."
  type        = string
}

variable "resource_owner" {
  description = "Owner of the resource."
  type        = string
  sensitive   = true
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
}

variable "sg_egress_protocol" {
  description = "List of egress protocols for security groups."
  type        = list(string)
}

variable "sg_ingress_protocol" {
  description = "List of ingress protocols for security groups."
  type        = list(string)
}

variable "ucname" {
  description = "Name of the Unity Catalog Metastore."
  type        = string
}

variable "vpc_cidr_range" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "workspace_vpce_service" {
  description = "VPCE service for the workspace REST API endpoint."
  type        = string
}