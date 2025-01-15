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
  type = map(string)
  default = {
    "civilian" = "discovery-search-rds-prod-dbdiscoverysearch-uus7j2cyyu1m.c40ji7ukhesx.us-gov-west-1.rds.amazonaws.com"
    "dod"      = "lineage-usgovwest1dod-prod.cpnejponioft.us-gov-west-1.rds.amazonaws.com"
  }
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

variable "databricks_gov_shard" {
  type = string
}