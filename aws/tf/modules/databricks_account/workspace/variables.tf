variable "scc_tunnel_dataplane_relay_access" {
  description = "ID of the SCC tunnel dataplane relay access interface endpoint."
  type        = string
}

variable "general_access" {
  description = "ID of the general access API interface endpoint."
  type        = string
}

variable "service_direct" {
  description = "List of service direct API interface endpoint IDs. Not available in GovCloud regions."
  type        = list(string)
  default     = []
}

variable "bucket_name" {
  description = "Name of the root S3 bucket for the workspace."
  type        = string
}

variable "cross_account_role_arn" {
  description = "AWS ARN of the cross-account role."
  type        = string
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "deployment_name" {
  description = "Deployment name for the workspace. Must first be enabled by a Databricks representative."
  type        = string
  default     = null
  nullable    = true
}

variable "managed_services_key" {
  description = "CMK for managed services."
  type        = string
}

variable "managed_services_key_alias" {
  description = "CMK for managed services alias."
  type        = string
}

variable "network_policy_id" {
  description = "Network policy ID for serverless compute."
  type        = string
}

variable "network_connectivity_configuration_id" {
  description = "Network connectivity configuration ID."
  type        = string
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "security_group_ids" {
  description = "Security group ID"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "workspace_storage_key" {
  description = "CMK for workspace storage."
  type        = string
}

variable "workspace_storage_key_alias" {
  description = "CMK for workspace storage alias."
  type        = string
}