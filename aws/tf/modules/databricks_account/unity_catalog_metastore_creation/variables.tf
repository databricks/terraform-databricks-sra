variable "metastore_exists" {
  description = "If a metastore exists."
  type        = string
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "custom_metastore_name" {
  description = "Optional name for the Unity Catalog metastore. If null, defaults to \"${"$"}{var.region}-unity-catalog\"."
  type        = string
  default     = null
  nullable    = true
}