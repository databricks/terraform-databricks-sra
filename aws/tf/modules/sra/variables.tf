variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string
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
  type        = list(string)
  description = "List of custom private subnet IDs"
  default     = null
}

variable "custom_relay_vpce_id" {
  type        = string
  description = "Custom Relay VPC Endpoint ID"
  default     = null
}

variable "custom_sg_id" {
  type        = string
  description = "Custom security group ID"
  default     = null
}

variable "custom_vpc_id" {
  type        = string
  description = "Custom VPC ID"
  default     = null
}

variable "custom_workspace_vpce_id" {
  type        = string
  description = "Custom Workspace VPC Endpoint ID"
  default     = null
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "enable_sat_boolean" {
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
  type        = string
  description = "The type of network set-up for the workspace network configuration."
  nullable    = false

  validation {
    condition     = contains(["custom", "isolated"], var.network_configuration)
    error_message = "Invalid network configuration. Allowed values are: sandbox, firewall, custom, isolated."
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
  type = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
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
  type = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
    #"us-west-1" = ""
  }
}
