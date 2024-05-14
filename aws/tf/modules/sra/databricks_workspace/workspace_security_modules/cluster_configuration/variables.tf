variable "resource_prefix" {
  type = string
}

variable "secret_config_reference" {
  type = string
}

variable "compliance_security_profile" {
  type        = bool
  description = "Add 2443 to security group configuration or nitro instance"
  nullable    = false
}