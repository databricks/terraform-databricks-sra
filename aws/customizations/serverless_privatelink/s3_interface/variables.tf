# =============================================================================
# Variables
# =============================================================================

variable "acceptance_required" {
  description = "Whether connection requests to the VPC endpoint service must be manually accepted. Keep true so you control which endpoints attach; the Databricks NCC private endpoint rule stays PENDING until you accept it."
  type        = bool
  default     = true
}

variable "allowed_principals" {
  description = "IAM principal ARNs allowed to create an interface endpoint to the VPC endpoint service. Defaults to the Databricks serverless private-connectivity role for the selected region and GovCloud shard (see locals). Set to [\"*\"] for the simplified allow-all approach from the Databricks docs."
  type        = list(string)
  default     = null
}

variable "databricks_gov_shard" {
  description = "GovCloud shard: \"civilian\" or \"dod\". Required when region is us-gov-west-1, where it selects the Databricks serverless private-connectivity role allowlisted on the VPC endpoint service. Defaults to null; ignored for commercial regions."
  type        = string
  default     = null

  validation {
    condition     = var.databricks_gov_shard == null || contains(["civilian", "dod"], var.databricks_gov_shard)
    error_message = "Allowed values for databricks_gov_shard are: null, civilian, dod."
  }

  validation {
    condition     = var.region != "us-gov-west-1" || contains(["civilian", "dod"], coalesce(var.databricks_gov_shard, "unset"))
    error_message = "databricks_gov_shard must be set to \"civilian\" or \"dod\" when region is us-gov-west-1."
  }
}

variable "health_check_interval" {
  description = "Interval in seconds between NLB target group health checks."
  type        = number
  default     = 10
}

variable "nlb_subnet_ids" {
  description = "Subnet IDs (one per Availability Zone) the internal NLB is placed in. Use at least two AZs; for cross-region serverless the endpoint service must span at least two AZs. Should align with s3_endpoint_subnet_ids so the NLB and the S3 interface endpoint ENIs share AZs."
  type        = list(string)

  validation {
    condition     = length(var.nlb_subnet_ids) >= 1
    error_message = "Provide at least one subnet ID for the NLB."
  }
}

variable "region" {
  description = "AWS region code. Commercial (e.g. us-east-1) or GovCloud (us-gov-west-1). Determines both the S3 service name for the interface endpoint and which Databricks serverless private-connectivity role is allowlisted on the VPC endpoint service."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix used for tagging resources (Project tag). The NLB and target group names use a fixed \"sra-\" prefix to stay within the 32-char AWS name limit, so this value can be any length."
  type        = string
}

variable "s3_endpoint_security_group_ids" {
  description = "Security group IDs attached to the S3 interface VPC endpoint. Must allow inbound TCP 443 from the NLB subnets/VPC CIDR so the NLB can reach the endpoint ENIs."
  type        = list(string)
}

variable "s3_endpoint_subnet_ids" {
  description = "Subnet IDs the S3 interface VPC endpoint places its ENIs in (one per AZ). Align these AZs with nlb_subnet_ids."
  type        = list(string)

  validation {
    condition     = length(var.s3_endpoint_subnet_ids) >= 1
    error_message = "Provide at least one subnet ID for the S3 interface endpoint."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the S3 interface endpoint, internal NLB, and its IP target group are created."
  type        = string
}
