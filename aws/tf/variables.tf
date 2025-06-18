variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string
}

variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
  default     = false
}

variable "aws_account_id" {
  description = "ID of the AWS account."
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
  default     = null
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
  description = "AWS region code. (e.g. us-east-1)"
  type        = string
  validation {
    condition     = contains(["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-1", "us-east-2", "us-west-2"], var.region)
    error_message = "Valid values for var: region are (ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1, us-east-2, us-west-2)."
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
  }
}

variable "system_table_bucket" {
  description = "System table bucket for VPC endpoint policy."
  type        = map(string)
  default = {
    "ap-northeast-1" = "system-tables-prod-ap-northeast-1-uc-metastore-bucket"
    "ap-northeast-2" = "system-tables-prod-ap-northeast-2-uc-metastore-bucket"
    "ap-south-1"     = "system-tables-prod-ap-south-1-uc-metastore-bucket"
    "ap-southeast-1" = "system-tables-prod-ap-southeast-1-uc-metastore-bucket"
    "ap-southeast-2" = "system-tables-prod-ap-southeast-2-uc-metastore-bucket"
    "ap-southeast-3" = "system-tables-prod-ap-southeast-3-uc-metastore-bucket"
    "ca-central-1"   = "system-tables-prod-ca-central-1-uc-metastore-bucket"
    "eu-central-1"   = "system-tables-prod-eu-central-1-uc-metastore-bucket"
    "eu-west-1"      = "system-tables-prod-eu-west-1-uc-metastore-bucket"
    "eu-west-2"      = "system-tables-prod-eu-west-2-uc-metastore-bucket"
    "eu-west-3"      = "system-tables-prod-eu-west-3-uc-metastore-bucket"
    "sa-east-1"      = "system-tables-prod-sa-east-1-uc-metastore-bucket"
    "us-east-1"      = "system-tables-prod-us-east-1-uc-metastore-bucket"
    "us-east-2"      = "system-tables-prod-us-east-2-uc-metastore-bucket"
    "us-west-1"      = "system-tables-prod-us-west-1-uc-metastore-bucket"
    "us-west-2"      = "system-tables-prod-us-west-2-uc-metastore-bucket"
  }
}



variable "log_storage_bucket" {
  description = "Log storage bucket for VPC endpoint policy."
  type        = map(string)
  default = {
    "ap-northeast-1" = "databricks-prod-storage-tokyo"
    "ap-northeast-2" = "databricks-prod-storage-seoul"
    "ap-south-1"     = "databricks-prod-storage-mumbai"
    "ap-southeast-1" = "databricks-prod-storage-singapore"
    "ap-southeast-2" = "databricks-prod-storage-sydney"
    "ap-southeast-3" = "databricks-prod-storage-jakarta"
    "ca-central-1"   = "databricks-prod-storage-montreal"
    "eu-central-1"   = "databricks-prod-storage-frankfurt"
    "eu-west-1"      = "databricks-prod-storage-ireland"
    "eu-west-2"      = "databricks-prod-storage-london"
    "eu-west-3"      = "databricks-prod-storage-paris"
    "sa-east-1"      = "databricks-prod-storage-saopaulo"
    "us-east-1"      = "databricks-prod-storage-virginia"
    "us-east-2"      = "databricks-prod-storage-ohio"
    "us-west-1"      = "databricks-prod-storage-oregon"
    "us-west-2"      = "databricks-prod-storage-oregon"
  }
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
    "ap-southeast-3" = "jakarta"
    "ca-central-1"   = "canada"
    "eu-central-1"   = "frankfurt"
    "eu-west-1"      = "ireland"
    "eu-west-2"      = "london"
    "eu-west-3"      = "paris"
    "sa-east-1"      = "saopaulo"
    "us-east-1"      = "nvirginia"
    "us-east-2"      = "ohio"
    "us-west-2"      = "oregon"
    "us-west-1"      = "oregon"
  }
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-.]{1,26}$", var.resource_prefix))
    error_message = "Invalid resource prefix. Allowed 40 characters containing only a-z, 0-9, -, ."
  }
}

variable "scc_relay" {
  description = "Secure Cluster Connectivity Relay PrivateLink Endpoint Map"
  type        = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    "ap-southeast-3" = "com.amazonaws.vpce.ap-southeast-3.vpce-svc-025ca447c232c6a1b"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
    "us-west-1"      = "com.amazonaws.vpce.us-west-1.vpce-svc-04cb91f9372b792fe"
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
  type        = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
    "ap-southeast-3" = "com.amazonaws.vpce.ap-southeast-3.vpce-svc-07a698e7e9ccfd04a"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
    "us-west-1"      = "com.amazonaws.vpce.us-west-1.vpce-svc-09bb6ca26208063f2"
  }
}