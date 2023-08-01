variable "databricks_account_id" {
  type = string
  sensitive = true
}

variable "client_id" {
  type = string
  sensitive = true
}

variable "client_secret" {
  type = string
  sensitive = true
}

variable "aws_account_id" {
  type = string
  sensitive = true
}

variable "resource_owner" {
  type = string
  sensitive = true
}

variable "resource_prefix" {
  type = string
}

variable "region" {
  type = string
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

variable "public_subnets_cidr" {
  type = list(string)
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


