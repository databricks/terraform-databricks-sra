<<<<<<< Updated upstream
=======
variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string
}

variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
  default     = false
}

>>>>>>> Stashed changes
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
    "ap-northeast-1" = "mddx5a4bpbpm05.cfrfsun7mryq.ap-northeast-1.rds.amazonaws.com"
    "ap-northeast-2" = "md1915a81ruxky5.cfomhrbro6gt.ap-northeast-2.rds.amazonaws.com"
    "ap-south-1"     = "mdjanpojt83v6j.c5jml0fhgver.ap-south-1.rds.amazonaws.com"
    "ap-southeast-1" = "md1n4trqmokgnhr.csnrqwqko4ho.ap-southeast-1.rds.amazonaws.com"
    "ap-southeast-2" = "mdnrak3rme5y1c.c5f38tyb1fdu.ap-southeast-2.rds.amazonaws.com"
    "ca-central-1"   = "md1w81rjeh9i4n5.co1tih5pqdrl.ca-central-1.rds.amazonaws.com"
    "eu-central-1"   = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
    "eu-west-1"      = "md15cf9e1wmjgny.cxg30ia2wqgj.eu-west-1.rds.amazonaws.com"
    "eu-west-2"      = "mdio2468d9025m.c6fvhwk6cqca.eu-west-2.rds.amazonaws.com"
    "eu-west-3"      = "metastorerds-dbconsolidationmetastore-asda4em2u6eg.c2ybp3dss6ua.eu-west-3.rds.amazonaws.com"
    "sa-east-1"      = "metastorerds-dbconsolidationmetastore-fqekf3pck8yw.cog1aduyg4im.sa-east-1.rds.amazonaws.com"
    "us-east-1"      = "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"
    "us-east-2"      = "md7wf1g369xf22.cluz8hwxjhb6.us-east-2.rds.amazonaws.com"
    "us-west-1"      = "mdzsbtnvk0rnce.c13weuwubexq.us-west-1.rds.amazonaws.com"
    "us-west-2"      = "mdpartyyphlhsp.caj77bnxuhme.us-west-2.rds.amazonaws.com"
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
