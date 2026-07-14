variable "endpoint_rate_limit_calls" {
  description = "Number of calls allowed per renewal period for each serving endpoint. The default of 0 intentionally blocks all traffic to every endpoint; raise it to allow calls."
  type        = number
  default     = 0
}

variable "endpoint_rate_limit_renewal_period" {
  description = "Renewal period for the rate limit. Only 'minute' is currently supported by the AI Gateway API."
  type        = string
  default     = "minute"
}
