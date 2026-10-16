# =============================================================================
# Variables
# =============================================================================

variable "allocated_storage" {
  description = "Allocated storage in GiB for the Oracle RDS instance."
  type        = number
  default     = 20
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the Oracle listeners (native port and tls_port). Include the subnet CIDRs of Databricks classic compute and of the internal NLB used for serverless PrivateLink, so the NLB can health-check and forward to the instance."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to reach the Oracle listeners (e.g. the Databricks classic-compute security group)."
  type        = list(string)
  default     = []
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups. Must be greater than 0 so the instance runs in ARCHIVELOG mode, which Lakeflow Connect CDC requires."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period > 0
    error_message = "backup_retention_period must be greater than 0 (ARCHIVELOG mode is required for CDC)."
  }
}

variable "ca_cert_identifier" {
  description = "RDS certificate authority that signs the instance's server certificate. The bundled rds-ca-rsa4096-g1.pem matches the default in us-gov-west-1; in other regions, the regional bundle from the ca_bundle_url output contains every RDS CA for that region."
  type        = string
  default     = "rds-ca-rsa4096-g1"
}

variable "db_name" {
  description = "Oracle database name (SID), used as the service name. Max 8 characters."
  type        = string
  default     = "ORCL"

  validation {
    condition     = length(var.db_name) <= 8
    error_message = "db_name must be at most 8 characters."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection on the RDS instance."
  type        = bool
  default     = false
}

variable "engine_version" {
  description = "Oracle engine version. Leave null to let RDS pick the current default for major_engine_version. List what is available with: aws rds describe-db-engine-versions --engine oracle-se2 --query 'DBEngineVersions[].EngineVersion'"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS instance class. Must support the chosen Oracle edition in the region."
  type        = string
  default     = "db.m5.large"
}

variable "major_engine_version" {
  description = "Oracle major engine version for the option group (e.g. 19)."
  type        = string
  default     = "19"
}

variable "master_username" {
  description = "Master username for the Oracle instance. Cannot be a reserved Oracle word."
  type        = string
  default     = "oracleadmin"
}

variable "multi_az" {
  description = "Deploy the RDS instance across multiple Availability Zones."
  type        = bool
  default     = false
}

variable "oracle_edition" {
  description = "Oracle RDS engine edition (e.g. oracle-se2, oracle-ee). Uses the license-included model."
  type        = string
  default     = "oracle-se2"
}

variable "port" {
  description = "Oracle native listener port."
  type        = number
  default     = 1521
}

variable "region" {
  description = "AWS region code. Commercial (e.g. us-east-1) or GovCloud (us-gov-west-1)."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix used for naming and tagging resources."
  type        = string
}

variable "subnet_ids" {
  description = "At least two private subnet IDs in different Availability Zones for the DB subnet group."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnet IDs in different Availability Zones."
  }
}

variable "tls_port" {
  description = "Oracle TCPS (TLS) listener port exposed by the SSL option. Federation connects here in Compliance Security Profile workspaces."
  type        = number
  default     = 2484
}

variable "vpc_id" {
  description = "ID of the VPC the RDS instance and its security group are created in (the workspace VPC, or a VPC reachable from it)."
  type        = string
}
