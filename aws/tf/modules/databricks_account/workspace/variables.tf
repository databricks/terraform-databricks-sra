variable "scc_tunnel_dataplane_relay_access" {
  description = "AWS VPC endpoint ID for the SCC tunnel dataplane relay access. Ignored when scc_relay_mws_vpce_id is set."
  type        = string
  default     = null
  nullable    = true
}

variable "scc_relay_mws_vpce_id" {
  description = "Pre-registered Databricks MWS VPC endpoint ID for the SCC tunnel dataplane relay access. If set, registration of the AWS VPC endpoint is skipped."
  type        = string
  default     = null
}

variable "general_access" {
  description = "AWS VPC endpoint ID for the general access (REST API) interface endpoint. Ignored when general_access_mws_vpce_id is set."
  type        = string
  default     = null
  nullable    = true
}

variable "general_access_mws_vpce_id" {
  description = "Pre-registered Databricks MWS VPC endpoint ID for the general access (REST API) endpoint. If set, registration of the AWS VPC endpoint is skipped."
  type        = string
  default     = null
}

variable "service_direct" {
  description = "List of service direct API interface AWS VPC endpoint IDs. Not available in GovCloud regions. Ignored when service_direct_mws_vpce_id is set."
  type        = list(string)
  default     = []
}

variable "service_direct_mws_vpce_id" {
  description = "Pre-registered Databricks MWS VPC endpoint ID for the service direct endpoint. If set, registration of the AWS VPC endpoint is skipped."
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "Name of the root S3 bucket for the workspace. Not used when compute_mode is SERVERLESS."
  type        = string
}

variable "compute_mode" {
  description = "Workspace compute mode. When SERVERLESS, the workspace is created without credentials, storage, network, private access settings, or customer-managed key configurations."
  type        = string
  default     = "HYBRID"

  validation {
    condition     = contains(["HYBRID", "SERVERLESS"], var.compute_mode)
    error_message = "Valid values for var: compute_mode are (HYBRID, SERVERLESS)."
  }
}

variable "cross_account_role_arn" {
  description = "AWS ARN of the cross-account role. Not used when compute_mode is SERVERLESS."
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

variable "workspace_display_name" {
  description = "Optional human-readable name for the workspace as shown in the Databricks UI. If null, falls back to resource_prefix."
  type        = string
  default     = null
  nullable    = true
}