# =============================================================================
# Variables
#
# These map to the databricks-solutions/dbx-proxy AWS module inputs (pinned to
# release v0.1.8 in main.tf). See that module's terraform/aws/README.md for full details.
# =============================================================================

variable "allowed_principals" {
  description = "IAM principal ARNs allowed to create an interface endpoint to the VPC endpoint service. Defaults to the Databricks serverless private-connectivity role for the selected region and GovCloud shard (see locals in main.tf). Set to [\"*\"] for the simplified allow-all approach from the Databricks docs."
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

variable "dbx_proxy_health_port" {
  description = "Port on which the dbx-proxy instances expose a TCP health check. Must not overlap any dbx_proxy_listener port."
  type        = number
  default     = 8080
}

variable "dbx_proxy_image_version" {
  description = "Docker image version for dbx-proxy."
  type        = string
  default     = "0.1.5"
}

variable "dbx_proxy_listener" {
  description = <<EOT
Logical dbx-proxy listener configuration. Each listener defines a frontend port and a set of routes
with destinations. mode is "tcp" (Layer 4) or "http" (Layer 7, SNI/host routing). For http listeners,
routes[].domains selects the backend by SNI/Host.
EOT
  type = list(object({
    name = string
    mode = string
    port = number
    routes = list(object({
      name    = string
      domains = list(string)
      destinations = list(object({
        name = string
        host = string
        port = number
      }))
    }))
  }))
  default = []
}

variable "dbx_proxy_max_connections" {
  description = "Override dbx-proxy maxconn. Defaults to a value derived from instance_type when null."
  type        = number
  default     = null
}

variable "deployment_mode" {
  description = "Deployment mode: \"bootstrap\" (create/use a VPC and a new NLB + endpoint service) or \"proxy-only\" (attach listeners/target groups to an existing NLB via nlb_arn). See the dbx-proxy README for the input combinations each mode requires."
  type        = string
  default     = "bootstrap"

  validation {
    condition     = contains(["bootstrap", "proxy-only"], var.deployment_mode)
    error_message = "deployment_mode must be one of: bootstrap, proxy-only."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create an Internet Gateway and NAT Gateway for outbound internet connectivity when bootstrapping a new VPC (needed to pull the dbx-proxy container image)."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type for dbx-proxy instances."
  type        = string
  default     = "t4g.medium"
}

variable "max_capacity" {
  description = "Maximum number of dbx-proxy instances in the autoscaling group."
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimum number of dbx-proxy instances in the autoscaling group."
  type        = number
  default     = 1
}

variable "nat_subnet_cidr" {
  description = "CIDR block for the public subnet used by the NAT gateway when bootstrapping a VPC."
  type        = string
  default     = "10.0.0.0/24"
}

variable "nlb_arn" {
  description = "Existing Network Load Balancer ARN to attach listeners/target groups to in proxy-only mode. Required when deployment_mode = \"proxy-only\"."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix for the AWS resource names created by the dbx-proxy module. When null, dbx-proxy generates one."
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region code. Commercial (e.g. us-east-1) or GovCloud (us-gov-west-1). Determines which Databricks serverless private-connectivity role is allowlisted on the VPC endpoint service; for GovCloud, combined with databricks_gov_shard."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix used for the Project tag on resources, matching the rest of SRA."
  type        = string
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets when bootstrapping a new VPC (at least two AZs for the endpoint service)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_ids" {
  description = "Existing subnet IDs for the NLB and proxy autoscaling group. Required in proxy-only mode; in bootstrap mode, leave empty to create new subnets from subnet_cidrs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources created by the dbx-proxy module."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC when bootstrapping a new VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "ID of an existing VPC to deploy into. Leave null in bootstrap mode to create a new VPC. Required (with subnet_ids) in proxy-only mode."
  type        = string
  default     = null
}
