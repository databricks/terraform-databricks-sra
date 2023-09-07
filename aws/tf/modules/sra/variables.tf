variable "databricks_account_id" {
  type      = string
  sensitive = true
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "aws_account_id" {
  type      = string
  sensitive = true
}

variable "resource_owner" {
  type      = string
  sensitive = true
}

variable "resource_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "region_name" {
  type = string
}

variable "metastore_id" {
  type      = string
  sensitive = true
}

variable "enable_logging_boolean" {
  type      = bool
  sensitive = true
}

variable "enable_firewall_boolean" {
  type      = bool
  sensitive = true
}

variable "enable_restrictive_root_bucket_boolean" {
  type      = bool
  sensitive = true
}

variable "dbfsname" {
  type = string
}

variable "ucname" {
  type = string
}

variable "data_bucket" {
  type = string
}

variable "data_access" {
  type = string
}

variable "vpc_cidr_range" {
  type = string
}

variable "private_subnets_cidr" {
  type = list(string)
}

variable "privatelink_subnets_cidr" {
  type = list(string)
}

variable "public_subnets_cidr" {
  type = list(string)
}

variable "firewall_subnets_cidr" {
  type = list(string)
}

variable "firewall_allow_list" {
  type = list(string)
}

variable "firewall_protocol_deny_list" {
  type = string
}


variable "availability_zones" {
  type = list(string)
}

variable "sg_egress_ports" {
  type = list(string)
}

variable "sg_ingress_protocol" {
  type = list(string)
}

variable "sg_egress_protocol" {
  type = list(string)
}

variable "workspace_vpce_service" {
  type = string
}

variable "relay_vpce_service" {
  type = string
}

variable "ip_addresses" {
  type = list(string)
}


