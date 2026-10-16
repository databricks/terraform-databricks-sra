# =============================================================================
# Variables
# =============================================================================

variable "acceptance_required" {
  description = "Whether connection requests to the VPC endpoint service must be manually accepted. Defaults to false so the allowlisted Databricks role is auto-accepted and the Unity Catalog connection (which validates connectivity on create) succeeds in a single apply. Set true to gate acceptance yourself; the NCC private endpoint rule then stays PENDING, and the connection fails to create, until you accept it."
  type        = bool
  default     = false
}

variable "allowed_principals" {
  description = "IAM principal ARNs allowed to create an interface endpoint to the VPC endpoint service. Defaults to the Databricks serverless private-connectivity role for the selected region and GovCloud shard (see locals). Set to [\"*\"] for the simplified allow-all approach from the Databricks docs."
  type        = list(string)
  default     = null
}

variable "connection_name" {
  description = "Name of the Unity Catalog connection to the Oracle database."
  type        = string
  default     = "oracle"
}

variable "databricks_account_id" {
  description = "Databricks account ID. Used by the account-level provider for the NCC private endpoint rule."
  type        = string
}

variable "databricks_gov_shard" {
  description = "GovCloud shard: \"civilian\" or \"dod\". Required when region is us-gov-west-1, where it selects the Databricks serverless private-connectivity role allowlisted on the VPC endpoint service and the Databricks account console host. Defaults to null; ignored for commercial regions."
  type        = string
  default     = null

  validation {
    condition     = var.databricks_gov_shard == null || contains(["civilian", "dod"], var.databricks_gov_shard)
    error_message = "Allowed values for databricks_gov_shard are: null, civilian, dod."
  }

  validation {
    condition     = var.region != "us-gov-west-1" || contains(["civilian", "dod"], coalesce(var.databricks_gov_shard, "unset"))
    error_message = "databricks_gov_shard must be set to \"civilian\" or \"dod\" when region is us-gov-west-1."
  }
}

variable "databricks_workspace_host" {
  description = "URL of the Databricks workspace the Unity Catalog connection and foreign catalog are created in (e.g. https://<workspace>.cloud.databricks.com, or .us for GovCloud)."
  type        = string
}

variable "foreign_catalog_name" {
  description = "Name of the Unity Catalog foreign catalog created over the Oracle connection."
  type        = string
  default     = "oracle"
}

variable "health_check_interval" {
  description = "Interval in seconds between NLB target group health checks."
  type        = number
  default     = 10
}

variable "ncc_id" {
  description = "ID of the Network Connectivity Configuration already bound to the workspace. The main SRA config creates and binds one; use its ncc_id output."
  type        = string
}

variable "nlb_port" {
  description = "Port the NLB listens on and advertises to serverless compute. Defaults to oracle_port so clients connect on the database's native TCPS port."
  type        = number
  default     = null
}

variable "nlb_subnet_ids" {
  description = "Subnet IDs (one per Availability Zone) the internal NLB is placed in. Use at least two AZs; for cross-region serverless the endpoint service must span at least two AZs."
  type        = list(string)

  validation {
    condition     = length(var.nlb_subnet_ids) >= 1
    error_message = "Provide at least one subnet ID for the NLB."
  }
}

variable "oracle_host" {
  description = "DNS hostname of the Oracle database (e.g. the RDS endpoint address). Registered as the NCC private endpoint rule domain name so serverless resolves it to the endpoint, and used as the connection host. Must match the server certificate's subject for TLS verification."
  type        = string
}

variable "oracle_ip_address" {
  description = "Private IP address of the Oracle database the NLB forwards to. NOTE: RDS private IPs can change on failover/maintenance; re-resolve and re-apply if it moves."
  type        = string
}

variable "oracle_password" {
  description = "Password for oracle_user. Stored in the Unity Catalog connection and in Terraform state; supply it via TF_VAR_oracle_password rather than a tfvars file."
  type        = string
  sensitive   = true
}

variable "oracle_port" {
  description = "Port of the Oracle TCPS (TLS) listener. On Amazon RDS for Oracle this is the port of the SSL option in the instance's option group (2484 by convention)."
  type        = number
  default     = 2484
}

variable "oracle_service_name" {
  description = "Oracle service name (on Amazon RDS for Oracle, the DB name, e.g. ORCL)."
  type        = string
}

variable "oracle_user" {
  description = "Oracle user the Unity Catalog connection authenticates as. For Lakeflow Connect CDC this must be a dedicated replication user created by dbx_oracle_setup_util (see cdc_setup); the connector rejects the RDS master user."
  type        = string
}

variable "region" {
  description = "AWS region code. Commercial (e.g. us-east-1) or GovCloud (us-gov-west-1). Determines which Databricks serverless private-connectivity role is allowlisted on the VPC endpoint service."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix used for tagging resources (Project tag). The NLB and target group names use a fixed \"sra-\" prefix to stay within the 32-char AWS name limit, so this value can be any length."
  type        = string
}

variable "server_certificate_path" {
  description = "Path to a PEM file containing the CA chain that signed the Oracle server certificate. Passed to the connection as userProvidedServerCertificate. For Amazon RDS for Oracle, use the regional RDS CA bundle (see example_db/rds_setup/rds-ca-rsa4096-g1.pem for us-gov-west-1)."
  type        = string

  validation {
    condition     = fileexists(var.server_certificate_path)
    error_message = "server_certificate_path must point to an existing PEM file."
  }
}

variable "vpc_id" {
  description = "ID of the VPC that can reach the Oracle database and where the internal NLB and its IP target group are created."
  type        = string
}
