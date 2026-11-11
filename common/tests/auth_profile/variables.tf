variable "auth_profile_name" {
  type        = string
  description = "Name of the ephemeral Databricks CLI auth profile to create/refresh for this test run."
}

variable "host" {
  type        = string
  description = "Fully-qualified workspace URL including https:// scheme. Callers normalize cloud-specific output shapes before passing."
}