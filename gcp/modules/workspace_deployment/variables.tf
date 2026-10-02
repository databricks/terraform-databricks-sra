
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

##### NAMING VARIABLES #####
variable "resource_prefix" {
  # Prefix applied to resource names. Final format: <prefix>-<resource>-<deployment_suffix>
  type        = string
  default     = "databricks"
  description = "Prefix for all resource names created by this module."
}

resource "random_string" "suffix" {
  # Random suffix for resource naming. Length kept at 6 to match legacy behavior
  # so existing deployments do not see the suffix regenerate on upgrade.
  special = false
  upper   = false
  length  = 6
}

locals {
  deployment_suffix = random_string.suffix.result
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

variable "databricks_control_plane_ips" {
  # Regional control-plane IPs used in the egress firewall rule (non-PSC mode only).
  # Look up the IPs for your region at:
  # https://docs.databricks.com/gcp/en/resources/ip-domain-region
  type        = list(string)
  default     = []
  description = "Databricks control-plane IPs for your region. Required when harden_network = true and use_psc = false. See https://docs.databricks.com/gcp/en/resources/ip-domain-region"
}

# Users can connect to workspace only from these IP addresses (via the workspace
# IP access list). Default allows all; set specific CIDRs to restrict access.
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

variable "public_access_enabled" {
  # Controls the public_access_enabled flag on the workspace's private access
  # settings (only relevant when use_psc or use_frontend_psc is set).
  #
  # Defaults to true to preserve reachability: this template configures back-end
  # PSC only and does NOT provision front-end PSC, so disabling public access
  # without a separate front-end private connection would lock users out of the
  # workspace UI/API. Set to false ONLY when front-end private connectivity is
  # in place, to make the workspace private-only.
  type        = bool
  default     = true
  description = "Whether the workspace is reachable over the public internet. Set to false for a private-only workspace once front-end private connectivity exists."
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

##### WORKSPACE SETTINGS #####
variable "manage_workspace_settings" {
  type        = bool
  default     = true
  description = <<-EOT
    Apply workspace-level settings (databricks_workspace_conf + IP access list).
    When true, the module also grants the provisioning service account workspace
    ADMIN so the workspace-scoped provider is authorized to apply them. Set to
    false if you manage these separately or the provisioning identity is not a
    databricks_user in the account.
  EOT
}

variable "workspace_conf" {
  type = map(string)
  default = {
    enableIpAccessLists    = "true"
    enableVerboseAuditLogs = "true"
    enableDbfsFileBrowser  = "false"
    maxTokenLifetimeDays   = "90"
  }
  description = "Workspace configuration (custom_config) applied via databricks_workspace_conf. Override to customize the default workspace hardening."
}

##### SERVERLESS / COMPUTE MODE #####
variable "serverless_workspace_deployment" {
  # Flag to deploy a serverless workspace (skips all network configuration).
  type        = bool
  default     = false
  description = "Set to true to deploy a serverless workspace. When enabled, all VPC, PSC, and network resources are skipped."
}
