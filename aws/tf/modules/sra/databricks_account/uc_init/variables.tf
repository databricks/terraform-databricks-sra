variable "metastore_exists" {
  description = "If a metastore exists."
  type        = string
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}