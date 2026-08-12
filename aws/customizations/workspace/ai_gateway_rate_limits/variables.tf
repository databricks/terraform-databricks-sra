variable "allow_zero_calls" {
  description = "Explicit confirmation that a zero-call rate limit should block all requests to every managed endpoint."
  type        = bool
  default     = false
}

variable "endpoint_rate_limit_calls" {
  description = "Number of calls allowed per renewal period for each managed serving endpoint. Must be set explicitly. Zero blocks all requests and also requires allow_zero_calls = true."
  type        = number

  validation {
    condition     = var.endpoint_rate_limit_calls >= 0 && floor(var.endpoint_rate_limit_calls) == var.endpoint_rate_limit_calls
    error_message = "endpoint_rate_limit_calls must be a non-negative integer."
  }
}

variable "endpoint_rate_limit_renewal_period" {
  description = "Renewal period for the rate limit. Only 'minute' is currently supported by the AI Gateway API."
  type        = string
  default     = "minute"

  validation {
    condition     = var.endpoint_rate_limit_renewal_period == "minute"
    error_message = "endpoint_rate_limit_renewal_period must be \"minute\"."
  }
}

variable "enforcement_revision" {
  description = "Operator-controlled revision used to force reapplication, for example after correcting configuration drift outside Terraform."
  type        = string
  default     = "1"

  validation {
    condition     = length(trimspace(var.enforcement_revision)) > 0
    error_message = "enforcement_revision must not be empty."
  }
}

variable "excluded_endpoint_names" {
  description = "Serving endpoint names to exclude from workspace-wide rate-limit enforcement."
  type        = set(string)
  default     = []
}
