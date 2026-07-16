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

variable "brokers" {
  description = "Kafka brokers to expose through the NLB. Each broker is advertised to serverless compute on its own dedicated listener port, forwarded to the broker's real IP and port. Assign every broker a unique nlb_port. The advertised.listeners on each broker must match the private DNS name and nlb_port so clients reconnect through the endpoint after bootstrap."
  type = list(object({
    name       = string
    ip_address = string
    port       = optional(number, 9094)
    nlb_port   = number
  }))

  validation {
    condition     = length(var.brokers) > 0
    error_message = "Provide at least one Kafka broker."
  }

  validation {
    condition     = length(distinct([for b in var.brokers : b.nlb_port])) == length(var.brokers)
    error_message = "Each broker must use a unique nlb_port."
  }

  validation {
    condition     = length(distinct([for b in var.brokers : b.name])) == length(var.brokers)
    error_message = "Each broker must have a unique name."
  }

  # Target group names are "sra-<broker.name>", so a broker name <= 28 keeps the
  # combined name within the 32-char AWS target group name limit.
  validation {
    condition     = alltrue([for b in var.brokers : length(b.name) <= 28])
    error_message = "Each broker name must be <= 28 characters to keep \"sra-<broker.name>\" within the 32-char AWS target group name limit."
  }
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
  description = "Subnet IDs (one per Availability Zone) the internal NLB is placed in. Use at least two AZs; for cross-region serverless the endpoint service must span at least two AZs."
  type        = list(string)

  validation {
    condition     = length(var.nlb_subnet_ids) >= 1
    error_message = "Provide at least one subnet ID for the NLB."
  }
}

variable "region" {
  description = "AWS region code. Commercial (e.g. us-east-1) or GovCloud (us-gov-west-1). Determines which Databricks serverless private-connectivity role is allowlisted on the VPC endpoint service."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix used for tagging resources (Project tag). The NLB and target group names use a fixed \"sra-\" prefix to stay within the 32-char AWS name limit, so this value can be any length."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that can reach the Kafka brokers and where the internal NLB and its IP target groups are created."
  type        = string
}
