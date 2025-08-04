variable "enable_compliance_security_profile" {
  description = "Flag to enable the compliance security profile."
  type        = bool
  sensitive   = true
  default     = false
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "region" {
  description = "AWS region code."
  type        = string
}