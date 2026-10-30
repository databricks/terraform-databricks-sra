variable "enable_private_network_gateway" {
  description = "Flag to create a private network gateway in the network connectivity configuration."
  type        = bool
  default     = false
}

variable "private_endpoint_rules" {
  description = "Optional private endpoint rules for serverless egress to customer AWS resources over PrivateLink. Each rule targets either a VPC endpoint service (endpoint_service, with optional domain_names for private DNS) or AWS resources such as S3 buckets (resource_names). Set key to a static, plan-time-known identifier when endpoint_service is a computed value (e.g. a VPC endpoint service created in the same apply); otherwise it defaults to the endpoint_service / resource_names value."
  type = list(object({
    key              = optional(string)
    domain_names     = optional(list(string))
    endpoint_service = optional(string)
    resource_names   = optional(list(string))
  }))
  default = []

  validation {
    condition     = alltrue([for rule in var.private_endpoint_rules : (rule.endpoint_service != null) != (rule.resource_names != null)])
    error_message = "Each private endpoint rule must set exactly one of endpoint_service or resource_names."
  }
}

variable "private_network_gateway" {
  description = "Private network gateway settings, used when enable_private_network_gateway is true; null otherwise. destinations are DNS names routed through the gateway and are only sent for the SPECIFIC_DESTINATIONS traffic mode."
  type = object({
    cross_account_role_arn = optional(string)
    destinations           = optional(list(string), [])
    security_group_ids     = optional(list(string))
    subnet_id              = optional(string)
    traffic_mode           = optional(string, "SPECIFIC_DESTINATIONS")
  })
  default = null
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}