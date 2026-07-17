variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.admin_user))
    error_message = "admin_user must be a valid email address."
  }
}

variable "artifact_storage_bucket" {
  description = "Artifact storage bucket for VPC endpoint policy."
  type        = map(list(string))
  default = {
    "ap-northeast-1" = ["databricks-prod-artifacts-ap-northeast-1"]
    "ap-northeast-2" = ["databricks-prod-artifacts-ap-northeast-2"]
    "ap-south-1"     = ["databricks-prod-artifacts-ap-south-1"]
    "ap-southeast-1" = ["databricks-prod-artifacts-ap-southeast-1"]
    "ap-southeast-2" = ["databricks-prod-artifacts-ap-southeast-2"]
    "ap-southeast-3" = ["databricks-prod-artifacts-ap-southeast-3"]
    "ca-central-1"   = ["databricks-prod-artifacts-ca-central-1"]
    "eu-central-1"   = ["databricks-prod-artifacts-eu-central-1"]
    "eu-west-1"      = ["databricks-prod-artifacts-eu-west-1"]
    "eu-west-2"      = ["databricks-prod-artifacts-eu-west-2"]
    "eu-west-3"      = ["databricks-prod-artifacts-eu-west-3"]
    "sa-east-1"      = ["databricks-prod-artifacts-sa-east-1"]
    "us-east-1"      = ["databricks-prod-artifacts-us-east-1"]
    "us-east-2"      = ["databricks-prod-artifacts-us-east-2"]
    "us-west-1"      = ["databricks-prod-artifacts-us-west-2"]
    "us-west-2"      = ["databricks-prod-artifacts-us-west-2", "databricks-update-oregon"]
    "us-gov-west-1"  = ["databricks-prod-artifacts-us-gov-west-1"]
  }
}

variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
  default     = false
}

variable "aws_account_id" {
  description = "ID of the AWS account. Not required when compute_mode is SERVERLESS, which creates no AWS resources."
  type        = string
  sensitive   = true
  default     = null
}

variable "aws_partition" {
  description = "AWS partition to use for ARNs and policies"
  type        = string
  default     = null # Will be computed based on region

  validation {
    condition     = var.aws_partition == null || can(contains(["aws", "aws-us-gov"], var.aws_partition))
    error_message = "Invalid AWS partition. Allowed values are: aws, aws-us-gov."
  }
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
  default     = null
}

variable "compliance_standards" {
  description = "List of compliance standards."
  type        = list(string)
  nullable    = true

  validation {
    condition     = alltrue([for standard in coalesce(var.compliance_standards, []) : can(regex("^[A-Z0-9_]+$", standard))])
    error_message = "compliance_standards entries must be uppercase standard identifiers such as HIPAA or PCI_DSS. Valid values: https://pkg.go.dev/github.com/databricks/databricks-sdk-go/service/settings#ComplianceStandard"
  }
}

variable "compute_mode" {
  description = "Workspace compute mode. HYBRID deploys the classic customer-managed VPC workspace with serverless available alongside. SERVERLESS deploys a serverless-only workspace: the customer VPC, PrivateLink endpoints, cross-account role, root S3 bucket, and workspace CMKs are skipped; the network policy, network connectivity configuration, and Unity Catalog resources still apply."
  type        = string
  default     = "HYBRID"

  validation {
    condition     = contains(["HYBRID", "SERVERLESS"], var.compute_mode)
    error_message = "Valid values for var: compute_mode are (HYBRID, SERVERLESS)."
  }
}

variable "context_based_ingress_ip_acl" {
  description = "Optional list of IP addresses/CIDRs used to limit access to the workspace based on IPs. Added to the network policy as ingress rules. Leave empty to apply no IP-based ingress restriction."
  type        = list(string)
  default     = []
}

variable "create_service_direct_vpce" {
  description = "Whether to create a Service Direct VPC endpoint for the workspace. Service Direct is a front-end endpoint that can be shared across workspaces in the same VPC, so customers typically reuse one rather than creating per-workspace."
  type        = bool
  default     = false
}

variable "custom_general_access_mws_vpce_id" {
  description = "Pre-registered Databricks MWS VPC Endpoint ID for General Access. If set, the AWS VPC endpoint is not re-registered with Databricks; this ID is wired directly into the workspace network configuration."
  type        = string
  default     = null
}

variable "custom_general_access_vpce_id" {
  description = "Custom General Access VPC Endpoint ID"
  type        = string
  default     = null
}

variable "custom_metastore_name" {
  description = "Optional name for the Unity Catalog metastore created by this deployment. If left blank/null, defaults to \"${"$"}{var.region}-unity-catalog\"."
  type        = string
  default     = null
  nullable    = true
}

variable "custom_private_subnet_ids" {
  description = "List of custom private subnet IDs"
  type        = list(string)
  default     = null
}

variable "custom_scc_relay_mws_vpce_id" {
  description = "Pre-registered Databricks MWS VPC Endpoint ID for SCC Tunnel Dataplane Relay Access. If set, the AWS VPC endpoint is not re-registered with Databricks; this ID is wired directly into the workspace network configuration."
  type        = string
  default     = null
}

variable "custom_scc_relay_vpce_id" {
  description = "Custom SCC Tunnel Dataplane Relay Access VPC Endpoint ID"
  type        = string
  default     = null
}

variable "custom_service_direct_mws_vpce_id" {
  description = "Pre-registered Databricks MWS VPC Endpoint ID for Service Direct. If set, the AWS VPC endpoint is not re-registered with Databricks."
  type        = string
  default     = null
}

variable "custom_service_direct_vpce_id" {
  description = "Custom Service Direct VPC Endpoint ID"
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

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "databricks_gov_shard" {
  description = "Databricks GovCloud shard type (civilian or dod). Only applicable for us-gov-west-1 region."
  type        = string
  default     = null

  validation {
    condition     = var.databricks_gov_shard == null || can(contains(["civilian", "dod"], var.databricks_gov_shard))
    error_message = "Invalid databricks_gov_shard. Allowed values are: null, civilian, dod."
  }
}

variable "databricks_provider_host" {
  description = "Databricks provider host URL"
  type        = string
  default     = null # Will be computed based on databricks_gov_shard

  validation {
    condition     = var.databricks_provider_host == null || can(regex("^https://(accounts|accounts-dod)\\.cloud\\.databricks\\.(com|us|mil)$", var.databricks_provider_host))
    error_message = "Invalid databricks_provider_host. Must be a valid Databricks accounts URL."
  }
}

variable "deployment_name" {
  description = "Deployment name for the workspace. Must first be enabled by a Databricks representative."
  default     = null
  type        = string
  nullable    = true
}

variable "disable_legacy_features_at_account_level" {
  description = "Flag to disable legacy features (e.g. Hive Metastore, DBFS, no-isolation shared clusters) for newly created workspaces at the account level. Affects all new workspaces in the Databricks account, not just this deployment."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_automatic_cluster_update" {
  description = "Flag to enable automatic cluster update. Automatically enabled when the compliance security profile is enabled."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_compliance_security_profile" {
  description = "Flag to enable the compliance security profile."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_enhanced_security_monitoring" {
  description = "Flag to enable enhanced security monitoring. Automatically enabled when the compliance security profile is enabled."
  type        = bool
  sensitive   = true
  default     = false
}

variable "enable_security_analysis_tool" {
  description = "Flag to enable the security analysis tool."
  type        = bool
  sensitive   = true
  default     = false
}

# General Access (Workspace API) PrivateLink Endpoint configuration
# This variable allows mapping regions to multiple endpoint properties:
# - primary_endpoint: The main endpoint service name (required)
# - secondary_endpoint: An optional secondary endpoint service name
# - region_type: Optional region type (defaults to "commercial", can be "govcloud")
#
# Example usage:
# var.general_access_config["us-gov-west-1"].primary_endpoint   # Get primary endpoint
# var.general_access_config["us-gov-west-1"].secondary_endpoint # Get secondary endpoint (if exists)
# var.general_access_config["us-gov-west-1"].region_type        # Get region type
variable "general_access_config" {
  description = "General Access (Workspace API) PrivateLink Endpoint configuration with multiple properties per region"
  type = map(object({
    primary_endpoint   = string
    secondary_endpoint = optional(string)
    region_type        = optional(string, "commercial")
  }))
  default = {
    "ap-northeast-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
    }
    "ap-northeast-2" = {
      primary_endpoint = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
    }
    "ap-south-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
    }
    "ap-southeast-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    }
    "ap-southeast-2" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
    }
    "ap-southeast-3" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-3.vpce-svc-07a698e7e9ccfd04a"
    }
    "ca-central-1" = {
      primary_endpoint = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
    }
    "eu-central-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    }
    "eu-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    }
    "eu-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    }
    "eu-west-3" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
    }
    "sa-east-1" = {
      primary_endpoint = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
    }
    "us-east-1" = {
      primary_endpoint = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    }
    "us-east-2" = {
      primary_endpoint = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    }
    "us-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
    }
    "us-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.us-west-1.vpce-svc-09bb6ca26208063f2"
    }
    "us-gov-west-1" = {
      primary_endpoint   = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-0f25e28401cbc9418"
      secondary_endpoint = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-08fddf710780b2a54"
      region_type        = "govcloud"
    }
  }
}

# Log storage bucket configuration
# This variable allows mapping regions to multiple bucket properties:
# - primary_bucket: The main bucket name (required)
# - secondary_bucket: An optional secondary bucket name (e.g., for DoD)
# - region_type: Optional region type (defaults to "commercial", can be "govcloud")
#
# Example usage:
# var.log_storage_bucket_config["us-gov-west-1"].primary_bucket   # Get primary bucket (civilian)
# var.log_storage_bucket_config["us-gov-west-1"].secondary_bucket # Get secondary bucket (DoD)
# var.log_storage_bucket_config["us-gov-west-1"].region_type      # Get region type
variable "log_storage_bucket_config" {
  description = "Log storage bucket configuration with multiple properties per region"
  type = map(object({
    primary_bucket   = string
    secondary_bucket = optional(string)
    region_type      = optional(string, "commercial")
  }))
  default = {
    "ap-northeast-1" = {
      primary_bucket = "databricks-prod-storage-tokyo"
    }
    "ap-northeast-2" = {
      primary_bucket = "databricks-prod-storage-seoul"
    }
    "ap-south-1" = {
      primary_bucket = "databricks-prod-storage-mumbai"
    }
    "ap-southeast-1" = {
      primary_bucket = "databricks-prod-storage-singapore"
    }
    "ap-southeast-2" = {
      primary_bucket = "databricks-prod-storage-sydney"
    }
    "ap-southeast-3" = {
      primary_bucket = "databricks-prod-storage-jakarta"
    }
    "ca-central-1" = {
      primary_bucket = "databricks-prod-storage-montreal"
    }
    "eu-central-1" = {
      primary_bucket = "databricks-prod-storage-frankfurt"
    }
    "eu-west-1" = {
      primary_bucket = "databricks-prod-storage-ireland"
    }
    "eu-west-2" = {
      primary_bucket = "databricks-prod-storage-london"
    }
    "eu-west-3" = {
      primary_bucket = "databricks-prod-storage-paris"
    }
    "sa-east-1" = {
      primary_bucket = "databricks-prod-storage-saopaulo"
    }
    "us-east-1" = {
      primary_bucket = "databricks-prod-storage-virginia"
    }
    "us-east-2" = {
      primary_bucket = "databricks-prod-storage-ohio"
    }
    "us-west-1" = {
      primary_bucket = "databricks-prod-storage-oregon"
    }
    "us-west-2" = {
      primary_bucket = "databricks-prod-storage-oregon"
    }
    "us-gov-west-1" = {
      primary_bucket   = "databricks-prod-storage-pendleton"
      secondary_bucket = "databricks-prod-storage-pendleton-dod"
      region_type      = "govcloud"
    }
  }
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
  default     = [null]
}

variable "privatelink_subnets_cidr" {
  description = "CIDR blocks for private link subnets."
  type        = list(string)
  nullable    = true
  default     = [null]
}

variable "region" {
  description = "AWS region code. (e.g. us-east-1)"
  type        = string
  validation {
    condition     = var.region != "us-gov-east-1"
    error_message = "us-gov-east-1 is not supported. Databricks on AWS GovCloud is only available in us-gov-west-1."
  }
  validation {
    condition     = contains(["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-1", "us-east-2", "us-west-1", "us-west-2", "us-gov-west-1"], var.region)
    error_message = "Valid values for var: region are (ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-southeast-3, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1, us-east-2, us-west-1, us-west-2, us-gov-west-1)."
  }
}

# Region name configuration
# This variable allows mapping regions to multiple name properties:
# - primary_name: The main region name (required)
# - secondary_name: An optional secondary region name (e.g., for DoD)
# - region_type: Optional region type (defaults to "commercial", can be "govcloud")
#
# Example usage:
# var.region_name_config["us-gov-west-1"].primary_name   # Get primary name (civilian)
# var.region_name_config["us-gov-west-1"].secondary_name # Get secondary name (DoD)
# var.region_name_config["us-gov-west-1"].region_type    # Get region type
variable "region_name_config" {
  description = "Region name configuration with multiple properties per region"
  type = map(object({
    primary_name   = string
    secondary_name = optional(string)
    region_type    = optional(string, "commercial")
  }))
  default = {
    "ap-northeast-1" = {
      primary_name = "tokyo"
    }
    "ap-northeast-2" = {
      primary_name = "seoul"
    }
    "ap-south-1" = {
      primary_name = "mumbai"
    }
    "ap-southeast-1" = {
      primary_name = "singapore"
    }
    "ap-southeast-2" = {
      primary_name = "sydney"
    }
    "ap-southeast-3" = {
      primary_name = "jakarta"
    }
    "ca-central-1" = {
      primary_name = "canada"
    }
    "eu-central-1" = {
      primary_name = "frankfurt"
    }
    "eu-west-1" = {
      primary_name = "ireland"
    }
    "eu-west-2" = {
      primary_name = "london"
    }
    "eu-west-3" = {
      primary_name = "paris"
    }
    "sa-east-1" = {
      primary_name = "saopaulo"
    }
    "us-east-1" = {
      primary_name = "nvirginia"
    }
    "us-east-2" = {
      primary_name = "ohio"
    }
    "us-west-2" = {
      primary_name = "oregon"
    }
    "us-west-1" = {
      primary_name = "oregon"
    }
    "us-gov-west-1" = {
      primary_name   = "pendleton"
      secondary_name = "pendleton-dod"
      region_type    = "govcloud"
    }
  }
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{1,26}$", var.resource_prefix))
    error_message = "Invalid resource prefix. Allowed 1-26 characters containing only a-z, 0-9, -"
  }
}

# Secure Cluster Connectivity Relay configuration
# This variable allows mapping regions to multiple endpoint properties:
# - primary_endpoint: The main endpoint service name (required)
# - secondary_endpoint: An optional secondary endpoint service name
# - region_type: Optional region type (defaults to "commercial", can be "govcloud")
#
# Example usage:
# var.scc_relay_config["us-gov-west-1"].primary_endpoint   # Get primary endpoint
# var.scc_relay_config["us-gov-west-1"].secondary_endpoint # Get secondary endpoint (if exists)
# var.scc_relay_config["us-gov-west-1"].region_type        # Get region type
variable "scc_relay_config" {
  description = "Secure Cluster Connectivity Relay configuration with multiple properties per region"
  type = map(object({
    primary_endpoint   = string
    secondary_endpoint = optional(string)
    region_type        = optional(string, "commercial")
  }))
  default = {
    "ap-northeast-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    }
    "ap-northeast-2" = {
      primary_endpoint = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    }
    "ap-south-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    }
    "ap-southeast-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    }
    "ap-southeast-2" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    }
    "ap-southeast-3" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-3.vpce-svc-025ca447c232c6a1b"
    }
    "ca-central-1" = {
      primary_endpoint = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    }
    "eu-central-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    }
    "eu-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    }
    "eu-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    }
    "eu-west-3" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    }
    "sa-east-1" = {
      primary_endpoint = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    }
    "us-east-1" = {
      primary_endpoint = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    }
    "us-east-2" = {
      primary_endpoint = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    }
    "us-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
    }
    "us-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.us-west-1.vpce-svc-04cb91f9372b792fe"
    }
    "us-gov-west-1" = {
      primary_endpoint   = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05f27abef1a1a3faa"
      secondary_endpoint = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05c210a2feea23ad7"
      region_type        = "govcloud"
    }
  }
}

variable "serverless_private_endpoint_rules" {
  description = "Optional private endpoint rules for serverless egress to customer AWS resources over PrivateLink, added to the network connectivity configuration. Each rule targets either a VPC endpoint service (endpoint_service, with optional domain_names for private DNS) or AWS resources such as S3 buckets (resource_names). Rules targeting your own VPC endpoint service must be accepted on the endpoint service side before they become established. Set key to a static, plan-time-known identifier when endpoint_service is a computed value (e.g. a VPC endpoint service created in the same apply); otherwise it defaults to the endpoint_service / resource_names value."
  type = list(object({
    key              = optional(string)
    domain_names     = optional(list(string))
    endpoint_service = optional(string)
    resource_names   = optional(list(string))
  }))
  default = []
}

# Service Direct PrivateLink Endpoint configuration
# This variable allows mapping regions to the service-direct endpoint properties:
# - primary_endpoint: The main endpoint service name (required)
# - region_type: Optional region type (defaults to "commercial")
#
# Note: Service Direct endpoints are not available in GovCloud regions.
#
# Example usage:
# var.service_direct_config["us-east-1"].primary_endpoint   # Get primary endpoint
# var.service_direct_config["us-east-1"].region_type        # Get region type
variable "service_direct_config" {
  description = "Service Direct PrivateLink Endpoint configuration with multiple properties per region"
  type = map(object({
    primary_endpoint = string
    region_type      = optional(string, "commercial")
  }))
  default = {
    "ap-northeast-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-00645ba5aa920181a"
    }
    "ap-northeast-2" = {
      primary_endpoint = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0eda2860bd3ffdc62"
    }
    "ap-south-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-south-1.vpce-svc-0f8cf0950ddb2df95"
    }
    "ap-southeast-1" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-095bb0c17301d018c"
    }
    "ap-southeast-2" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0bad186019cff33de"
    }
    "ap-southeast-3" = {
      primary_endpoint = "com.amazonaws.vpce.ap-southeast-3.vpce-svc-028527b0920c3e620"
    }
    "ca-central-1" = {
      primary_endpoint = "com.amazonaws.vpce.ca-central-1.vpce-svc-0a677b49b6d71cf54"
    }
    "eu-central-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-central-1.vpce-svc-040453426d7a48946"
    }
    "eu-north-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-north-1.vpce-svc-034c0ab59f7a99d04"
    }
    "eu-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-1.vpce-svc-0a5d3be4f026f5bd7"
    }
    "eu-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-2.vpce-svc-000fc680ee188fcf6"
    }
    "eu-west-3" = {
      primary_endpoint = "com.amazonaws.vpce.eu-west-3.vpce-svc-041f8eb165985a7eb"
    }
    "sa-east-1" = {
      primary_endpoint = "com.amazonaws.vpce.sa-east-1.vpce-svc-09d56640b3fed29b8"
    }
    "us-east-1" = {
      primary_endpoint = "com.amazonaws.vpce.us-east-1.vpce-svc-0a1a39ada4ec3bcdc"
    }
    "us-east-2" = {
      primary_endpoint = "com.amazonaws.vpce.us-east-2.vpce-svc-052fbd90ec8e1af31"
    }
    "us-west-1" = {
      primary_endpoint = "com.amazonaws.vpce.us-west-1.vpce-svc-070673a01d3f28066"
    }
    "us-west-2" = {
      primary_endpoint = "com.amazonaws.vpce.us-west-2.vpce-svc-0d7fe235ba1abe9d2"
    }
  }
}

# Service Direct PrivateLink limited AZ regions
# Some regions only support service-direct PrivateLink in specific availability zones.
# Regions not listed here support all availability zones.
#
# Reference: https://docs.databricks.com/aws/en/security/network/front-end/service-direct-privatelink#availability-zone-support
variable "service_direct_limited_az_regions" {
  description = "Regions with limited AZ support for service-direct PrivateLink. Maps region to list of supported AZ IDs."
  type        = map(list(string))
  default = {
    "ap-northeast-1" = ["apne1-az1", "apne1-az2", "apne1-az4"]
    "ap-northeast-2" = ["apne2-az1", "apne2-az3"]
    "us-east-1"      = ["use1-az1", "use1-az2", "use1-az4"]
    "us-west-2"      = ["usw2-az1", "usw2-az2", "usw2-az3"]
  }
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
  nullable    = true
  default     = [null]
}

variable "shared_datasets_bucket" {
  description = "Shared datasets bucket for VPC endpoint policy."
  type        = map(string)
  default = {
    "ap-northeast-1" = "databricks-datasets-tokyo"
    "ap-northeast-2" = "databricks-datasets-seoul"
    "ap-south-1"     = "databricks-datasets-mumbai"
    "ap-southeast-1" = "databricks-datasets-singapore"
    "ap-southeast-2" = "databricks-datasets-sydney"
    "ap-southeast-3" = "databricks-datasets-oregon"
    "ca-central-1"   = "databricks-datasets-montreal"
    "eu-central-1"   = "databricks-datasets-frankfurt"
    "eu-west-1"      = "databricks-datasets-ireland"
    "eu-west-2"      = "databricks-datasets-london"
    "eu-west-3"      = "databricks-datasets-paris"
    "sa-east-1"      = "databricks-datasets-saopaulo"
    "us-east-1"      = "databricks-datasets-virginia"
    "us-east-2"      = "databricks-datasets-ohio"
    "us-west-1"      = "databricks-datasets-oregon"
    "us-west-2"      = "databricks-datasets-oregon"
    "us-gov-west-1"  = "databricks-datasets-pendleton"
  }
}

# System table bucket configuration
# This variable allows mapping regions to multiple bucket properties:
# - primary_bucket: The main bucket name (required)
# - secondary_bucket: An optional secondary bucket name (e.g., for DoD)
# - region_type: Optional region type (defaults to "commercial", can be "govcloud")
#
# Example usage:
# var.system_table_bucket_config["us-gov-west-1"].primary_bucket   # Get primary bucket (civilian)
# var.system_table_bucket_config["us-gov-west-1"].secondary_bucket # Get secondary bucket (DoD)
# var.system_table_bucket_config["us-gov-west-1"].region_type      # Get region type
variable "system_table_bucket_config" {
  description = "System table bucket configuration with multiple properties per region"
  type = map(object({
    primary_bucket   = string
    secondary_bucket = optional(string)
    region_type      = optional(string, "commercial")
  }))
  default = {
    "ap-northeast-1" = {
      primary_bucket = "system-tables-prod-ap-northeast-1-uc-metastore-bucket"
    }
    "ap-northeast-2" = {
      primary_bucket = "system-tables-prod-ap-northeast-2-uc-metastore-bucket"
    }
    "ap-south-1" = {
      primary_bucket = "system-tables-prod-ap-south-1-uc-metastore-bucket"
    }
    "ap-southeast-1" = {
      primary_bucket = "system-tables-prod-ap-southeast-1-uc-metastore-bucket"
    }
    "ap-southeast-2" = {
      primary_bucket = "system-tables-prod-ap-southeast-2-uc-metastore-bucket"
    }
    "ap-southeast-3" = {
      primary_bucket = "system-tables-prod-ap-southeast-3-uc-metastore-bucket"
    }
    "ca-central-1" = {
      primary_bucket = "system-tables-prod-ca-central-1-uc-metastore-bucket"
    }
    "eu-central-1" = {
      primary_bucket = "system-tables-prod-eu-central-1-uc-metastore-bucket"
    }
    "eu-west-1" = {
      primary_bucket = "system-tables-prod-eu-west-1-uc-metastore-bucket"
    }
    "eu-west-2" = {
      primary_bucket = "system-tables-prod-eu-west-2-uc-metastore-bucket"
    }
    "eu-west-3" = {
      primary_bucket = "system-tables-prod-eu-west-3-uc-metastore-bucket"
    }
    "sa-east-1" = {
      primary_bucket = "system-tables-prod-sa-east-1-uc-metastore-bucket"
    }
    "us-east-1" = {
      primary_bucket = "system-tables-prod-us-east-1-uc-metastore-bucket"
    }
    "us-east-2" = {
      primary_bucket = "system-tables-prod-us-east-2-uc-metastore-bucket"
    }
    "us-west-1" = {
      primary_bucket = "system-tables-prod-us-west-1-uc-metastore-bucket"
    }
    "us-west-2" = {
      primary_bucket = "system-tables-prod-us-west-2-uc-metastore-bucket"
    }
    "us-gov-west-1" = {
      primary_bucket   = "system-tables-prod-us-gov-west-1-gov-uc-metastore-bucket"
      secondary_bucket = "system-tables-prod-us-dod-west-1-gov-uc-metastore-bucket"
      region_type      = "govcloud"
    }
  }
}

variable "vpc_cidr_range" {
  description = "CIDR range for the VPC."
  type        = string
  nullable    = true
  default     = null
}

variable "workspace_display_name" {
  description = "Optional human-readable name for the workspace as shown in the Databricks UI. If not set, defaults to var.resource_prefix."
  type        = string
  default     = null
  nullable    = true
}

# Combined locals block for all computed values, ordered alphabetically
locals {
  # Compute the correct AWS partition for assume role policies
  # Different partitions based on region and GovCloud shard type
  assume_role_partition = var.region == "us-gov-west-1" ? (
    var.databricks_gov_shard == "dod" ? "aws-us-gov-dod" : "aws-us-gov"
  ) : "aws"

  # Computed AWS partition based on region
  computed_aws_partition = var.aws_partition != null ? var.aws_partition : (
    var.region == "us-gov-west-1" ? "aws-us-gov" : "aws"
  )

  # Computed Databricks provider host based on GovCloud shard
  computed_databricks_provider_host = var.databricks_provider_host != null ? var.databricks_provider_host : (
    var.databricks_gov_shard == "dod" ? "https://accounts-dod.cloud.databricks.mil" : (
      var.databricks_gov_shard == "civilian" ? "https://accounts.cloud.databricks.us" : "https://accounts.cloud.databricks.com"
    )
  )

  # Compute the correct Databricks account ID for artifact buckets
  # Both GovCloud civilian and DoD shards use the same account ID for artifact buckets
  databricks_artifact_and_sample_data_account_id = var.databricks_gov_shard == "civilian" || var.databricks_gov_shard == "dod" ? "282567162347" : "414351767826"

  # Compute the correct Databricks account ID based on GovCloud shard
  databricks_aws_account_id = var.databricks_gov_shard == "civilian" ? "044793339203" : (
    var.databricks_gov_shard == "dod" ? "170661010020" : "414351767826"
  )

  # Compute the correct Databricks account ID for EC2 images
  # GovCloud regions use a different account ID for AMIs
  databricks_ec2_image_account_id = var.region == "us-gov-west-1" ? "044732911619" : "601306020600"

  # Serverless-only workspaces skip the customer-managed VPC, PrivateLink endpoints,
  # cross-account role, root S3 bucket, and workspace CMKs
  is_serverless = var.compute_mode == "SERVERLESS"

  # Whether a Service Direct VPC endpoint should be associated with the workspace, expressed purely from
  # plain variables (no resource-derived values). Mirrors exactly when the module's service_direct argument
  # resolves to a non-empty list, and is passed to the workspace module as service_direct_enabled so the
  # module's count is statically resolvable during terraform import and other partial-state operations
  # without temporarily editing service_direct to [].
  service_direct_enabled = !local.is_serverless && var.custom_service_direct_mws_vpce_id == null && (
    var.custom_service_direct_vpce_id != null || (
      var.create_service_direct_vpce && var.network_configuration != "custom" && contains(keys(var.service_direct_config), var.region)
    )
  )

  # Compute the correct Unity Catalog IAM ARN based on region and GovCloud shard type
  unity_catalog_iam_arn = var.region == "us-gov-west-1" ? (
    var.databricks_gov_shard == "dod" ? "arn:aws-us-gov:iam::170661010020:role/unity-catalog-prod-UCMasterRole-1DI6DL6ZP26AS" : "arn:aws-us-gov:iam::044793339203:role/unity-catalog-prod-UCMasterRole-1QRFA8SGY15OJ"
  ) : "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}
