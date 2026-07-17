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

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}