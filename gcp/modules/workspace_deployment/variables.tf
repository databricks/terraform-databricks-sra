
##### GENERAL VARIABLES #####
variable "databricks_account_id" {
  # Databricks account ID (found in the account console)
}

variable "databricks_google_service_account" {
  # Google service account for Databricks
  # This service account must have the "Databricks Workspace Creator" role or equivalent
  # and the "Databricks Account Admin" role in the Databricks account console
}

variable "google_project" {
  # Name of the Google Cloud project
}

variable "google_region" {
  # Google Cloud region
}

variable "account_console_url" {
  # Databricks account console URL
  default = "https://accounts.gcp.databricks.com"
}

variable "workspace_name" {
  # Name you want to give to the Databricks workspace you are creating
  default = "sra-deployed-ws"
}

variable "databricks_google_service_account_key" {
  # Base64 encoded service account key for the Google service account
  # This is optional and can be used if you want to authenticate using a key file
  default = ""
}

##### NAMING VARIABLES #####
variable "deployment_id" {
  # Unique deployment ID used for naming. If empty, a random suffix is generated.
  # When provided (e.g., a UUID from a backend), the first 8 characters are used.
  type        = string
  default     = ""
  description = "Unique deployment ID. Leave empty to auto-generate a random 8-char suffix."
}

variable "resource_prefix" {
  # Prefix applied to resource names. Final format: <prefix>-<resource>-<deployment_suffix>
  type        = string
  default     = "databricks"
  description = "Prefix for all resource names created by this module."
}

resource "random_string" "suffix" {
  # Fallback suffix when var.deployment_id is not provided.
  # Length kept at 6 to match the legacy behavior so existing deployments do
  # not see the suffix regenerate on upgrade.
  count   = var.deployment_id == "" ? 1 : 0
  special = false
  upper   = false
  length  = 6
}

locals {
  deployment_suffix = var.deployment_id != "" ? substr(var.deployment_id, 0, 8) : random_string.suffix[0].result
}

##### NETWORKING VARIABLES #####
variable "use_existing_vpc" {
  # Flag to use an existing VPC
  default = false
}

variable "existing_vpc_name" {
  # Name of the existing VPC. Keep it empty if you want to create a new one.
  default = ""
}

variable "existing_subnet_name" {
  # Name of the existing subnet. Keep it empty if you want to create a new one.
  default = ""
}

variable "nodes_ip_cidr_range" {
  # CIDR range for nodes. See https://docs.databricks.com/gcp/en/admin/cloud-configurations/gcp/network-sizing
  # Important: this cannot be changed after the workspace is created.
  default = "10.0.0.0/16"
}

variable "use_existing_PSC_EP" {
  # Flag to use an existing PSC endpoint
  default = false
}

variable "google_pe_subnet" {
  # Name of the subnet to be used for the PSC endpoints
  default = "databricks-pe-subnet"
}

variable "google_pe_subnet_ip_cidr_range" {
  # CIDR range for private endpoint subnet
  default = "10.3.0.0/24"
}

variable "workspace_pe" {
  # Name of the PSC endpoint (found in GCP console) used for the workspace communication
  default = "workspace-pe"
}

variable "relay_pe" {
  # Name of the PSC endpoint (found in the GCP console) used for the relay communication
  default = "relay-pe"
}

variable "workspace_pe_ip_name" {
  # Workspace private endpoint IP name
  default = ""
}

variable "relay_pe_ip_name" {
  # Name of the relay private endpoint IP
  default = ""
}

variable "harden_network" {
  # Flag to enable network hardening with firewall rules
  default = true
}

variable "hive_metastore_ip" {
  # For the value of the regional Hive Metastore IP, refer to the Databricks documentation:
  # https://docs.gcp.databricks.com/en/resources/ip-domain-region.html
  default = "34.76.244.202" # Value for europe-west1 region
}

# Users can connect to workspace only from these IP addresses
variable "ip_addresses" {
  # List of allowed IP addresses
  type    = list(string)
  default = ["0.0.0.0/0"] # Default allows all IPs. Change to restrict access.
}

variable "relay_service_attachment" {
  # Relay service attachment. Regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
  default = ""
}

variable "workspace_service_attachment" {
  # Workspace service attachment. Regional values - https://docs.gcp.databricks.com/resources/supported-regions.html#psc
  default = ""
}

variable "use_existing_pas" {
  # Flag to use an existing private access settings (rare)
  default = false
}

variable "existing_pas_id" {
  # ID of the existing private access settings (only needed if use_existing_pas is true)
  default = ""
}

##### CMEK VARIABLES #####
variable "use_cmek" {
  # Master flag: enable Customer-Managed Encryption Keys for the workspace
  type        = bool
  default     = false
  description = "Set to true to use Customer-Managed Encryption Keys (CMEK) for workspace encryption."
}

variable "use_existing_cmek" {
  # Flag to use an existing CMEK (only honored if use_cmek = true)
  default = false
}

variable "key_name" {
  # Key name for CMEK. Only used when creating a new CMEK.
  default = "sra-key"
}

variable "keyring_name" {
  # Keyring name for CMEK. Only used when creating a new CMEK.
  default = "sra-keyring"
}

variable "cmek_resource_id" {
  # Resource ID for CMEK. Only needed if use_existing_cmek is true.
  default = ""
}

##### PSC / CONNECTIVITY VARIABLES #####
variable "use_psc" {
  # Flag to use Private Service Connect (PSC) for the workspace (backend PSC)
  default = false
}

variable "use_frontend_psc" {
  # Flag to enable frontend Private Service Connect
  type        = bool
  default     = false
  description = "Set to true to enable frontend Private Service Connect (PSC) for the workspace."
}

variable "use_existing_databricks_vpc_eps" {
  # Flag to use existing Databricks VPC Endpoints for PSC
  default = false
}

variable "existing_databricks_vpc_ep_workspace" {
  default = ""
}

variable "existing_databricks_vpc_ep_relay" {
  default = ""
}

variable "existing_workspace_psc_endpoint_ip" {
  type        = string
  default     = ""
  description = "IP address of the existing workspace PSC endpoint, used for DNS A-records. Only needed if use_existing_PSC_EP is true."
}

variable "existing_relay_psc_endpoint_ip" {
  type        = string
  default     = ""
  description = "IP address of the existing relay (SCC tunnel) PSC endpoint, used for the tunnel DNS A-record. Only needed if use_existing_PSC_EP is true."
}

##### DNS VARIABLES #####
variable "create_dns_zone" {
  # If true, create a new private DNS zone for gcp.databricks.com and add A-records for the workspace.
  # If false and existing_dns_zone_name is empty, no DNS resources are created (user manages DNS manually).
  type        = bool
  default     = false
  description = "Create a private DNS zone for gcp.databricks.com. Takes precedence over existing_dns_zone_name."
}

variable "dns_zone_name" {
  # Name for the private DNS zone (only used when create_dns_zone = true)
  type        = string
  default     = "databricks-private-zone"
  description = "Name of the private DNS zone to create (only used when create_dns_zone = true)."
}

variable "existing_dns_zone_name" {
  # Name of an existing private DNS zone to add A-records to.
  # Leave empty if you use create_dns_zone or manage DNS manually.
  type        = string
  default     = ""
  description = "Name of an existing private DNS zone to add A-records to."
}

##### ADMIN / USER VARIABLES #####
variable "resource_owner" {
  # Email address of the user to be granted admin access to the workspace
  type        = string
  default     = ""
  description = "Email of the user to be granted admin access to the workspace."
}

variable "skip_user_lookup" {
  # Skip user lookup data sources. Use for destroy operations when the resource_owner
  # user may no longer exist in the account.
  type        = bool
  default     = false
  description = "Skip user lookup data sources (useful for destroy operations)."
}

variable "admin_user_email" {
  # Legacy: email address of the admin user to be added to the workspace.
  # Prefer resource_owner going forward.
  type        = string
  default     = ""
  description = "Legacy admin user email. Prefer var.resource_owner."
}

variable "can_create_workspaces" {
  # Flag indicating whether the service account has permission to create workspaces
  type        = bool
  default     = true
  description = "Flag indicating the service account is ready to create workspaces."
}

variable "create_admin_user" {
  # Legacy flag to create an admin user in the workspace
  type        = bool
  default     = false
  description = "Legacy flag to create the admin user in the workspace."
}

##### METASTORE VARIABLES #####
variable "regional_metastore_id" {
  # ID of the regional Unity Catalog metastore
  default = ""
}

variable "default_catalog_name" {
  type        = string
  default     = "default_catalog"
  description = <<-EOT
    Name of an existing catalog in the assigned metastore to set as the workspace's
    default namespace. Defaults to "default_catalog" (the Databricks auto-created
    catalog). Set to a different existing catalog name to point the workspace at it,
    or set to "" to skip managing the default namespace and leave it at the
    Databricks-assigned default. The module does NOT create the catalog — it must
    already exist in the metastore.
  EOT
}

variable "provision_regional_metastore" {
  # Flag to provision a regional metastore
  default = false
}

##### SERVERLESS / COMPUTE MODE #####
variable "serverless_workspace_deployment" {
  # Flag to deploy a serverless workspace (skips all network configuration).
  type        = bool
  default     = false
  description = "Set to true to deploy a serverless workspace. When enabled, all VPC, PSC, and network resources are skipped."
}
