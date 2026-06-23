variable "context_based_ingress_ip_acl" {
  description = "Optional list of IP addresses/CIDRs used to limit access to the workspace based on IPs. Added to the network policy as ingress rules. Leave empty to apply no IP-based ingress restriction."
  type        = list(string)
  default     = []
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "enable_security_analysis_tool" {
  description = "Flag to enable the security analysis tool. When true, PyPI is added to the egress allow list so SAT can install its dependencies."
  type        = bool
  default     = false
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}