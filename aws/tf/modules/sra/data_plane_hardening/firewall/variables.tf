variable "availability_zones" {
  type = list(string)
}

variable "firewall_allow_list" {
  type = list(string)
}

variable "firewall_subnets_cidr" {
  type = list(string)
}

variable "hive_metastore_fqdn" {
  type = string
}

variable "private_subnet_rt" {
  type = list(string)
}

variable "private_subnets_cidr" {
  type = list(string)
}

variable "public_subnets_cidr" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "vpc_cidr_range" {
  type = string
}

variable "vpc_id" {
  type = string
}
