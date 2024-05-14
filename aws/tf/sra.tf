module "SRA" {
  source = "./modules/sra"

  providers = {
    databricks.mws = databricks.mws
    aws            = aws
  }

  // Authentication Variables
  databricks_account_id = var.databricks_account_id
  client_id             = var.client_id
  client_secret         = var.client_secret
  aws_account_id        = var.aws_account_id
  region                = var.region
  region_name           = var.region_name[var.region]

  // Naming and tagging variables:
  resource_prefix = var.resource_prefix
  resource_owner  = var.resource_owner

  // Account - general
  enable_logging_boolean = false // Logging configuration - set to true if you'd like to set-up billing and audit log delivery to an S3 bucket. System tables can be used as an alternative with no set-up.
  user_workspace_admin   = null  // REQUIRED - Admin workspace user (e.g. firstname.lastname@company.com)

  // Account - Unity Catalog:
  metastore_id            = null // Metastore configuration - leave null if there is no existing regional metastore, does not create a root storage location
  metastore_name          = join("", [var.resource_prefix, "-", var.region, "-", "uc"])
  data_bucket             = null // REQUIRED - Existing S3 bucket name (e.g. data-bucket-s3-test)
  workspace_catalog_admin = null // REQUIRED - Workspace specific catalogs are created, this user will become an admin of that catalog (e.g. firstname.lastname@company.com)
  external_location_admin = null // REQUIRED - Read-only external location is created, this user will become an admin of that exteranl location (e.g. firstname.lastname@company.com)

  // Workspace - operation mode:
  operation_mode              = "sandbox" // REQUIRED - Accepted values: sandbox, custom, firewall, or isolated. https://github.com/databricks/terraform-databricks-sra/blob/main/aws/tf/README.md#operation-mode
  compliance_security_profile = false     // REQUIRED - If you are using compliance security profile, please enable this to true. This adds port 2443 (FIPS) as a security group rule.

  // Workspace - AWS non-networking variables:
  dbfsname                         = join("", [var.resource_prefix, "-", var.region, "-", "dbfsroot"])
  cmk_admin_arn                    = null  // If not provided, the root user of the AWS account is used
  enable_cluster_boolean           = false // WARNING: Clusters will spin-up Databricks clusters and AWS EC2 instances
  enable_admin_configs             = false // WARNING: The workspace_conf resource is evolving API that may change from provider to provider. Please review the in-resource documentation (admin_configuration.tf) before enabling.
  workspace_service_principal_name = "sra-example-sp"
  deployment_name                  = var.deployment_name

  // Workspace - networking variables (optional if using custom operation mode):
  vpc_cidr_range           = "10.0.0.0/18"
  private_subnets_cidr     = ["10.0.16.0/22", "10.0.24.0/22"]
  privatelink_subnets_cidr = ["10.0.32.0/26", "10.0.32.64/26"]
  public_subnets_cidr      = ["10.0.32.128/26", "10.0.32.192/26"]
  availability_zones       = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  sg_egress_ports          = [443, 3306, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]
  sg_ingress_protocol      = ["tcp", "udp"]
  sg_egress_protocol       = ["tcp", "udp"]
  relay_vpce_service       = var.scc_relay[var.region]
  workspace_vpce_service   = var.workspace[var.region]

  // Workspace - networking variables (required if using custom operation mode):
  custom_vpc_id             = null
  custom_private_subnet_ids = null // list of strings required
  custom_sg_id              = null
  custom_relay_vpce_id      = null
  custom_workspace_vpce_id  = null

  // Workspace - networking variables (required if using firewall operation mode):
  firewall_subnets_cidr       = ["10.0.33.0/26", "10.0.33.64/26"]
  firewall_allow_list         = [".pypi.org", ".cran.r-project.org", ".pythonhosted.org", ".spark-packages.org", ".maven.org", "maven.apache.org", ".storage-download.googleapis.com"]
  firewall_protocol_deny_list = "IP"
  hive_metastore_fqdn         = "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com" //

  // Workspace - restrictive AWS asset policies (optional):
  enable_restrictive_root_bucket_boolean      = false
  enable_restrictive_s3_endpoint_boolean      = false
  enable_restrictive_sts_endpoint_boolean     = false
  enable_restrictive_kinesis_endpoint_boolean = false

  // Workspace - IP access list (optional):
  enable_ip_boolean = false
  ip_addresses      = ["X.X.X.X", "X.X.X.X/XX", "X.X.X.X/XX"] // WARNING: Please validate that IPs entered are correct, recommend setting a break glass IP in case of a lockout

  // Public Preview - System Tables Schemas (optional, if system tables audit log alerting is set to true and system table schemas are not enabled then it is required):
  enable_system_tables_schema = false // WARNING: This feature is in public preview: https://docs.databricks.com/en/administration-guide/system-tables/index.html#enable-system-table-schemas

  // Solution Accelerator - Security Analysis Tool (optional):
  enable_sat_boolean = false // WARNING: Security analysis tool spins-up jobs and clusters. More information here: https://github.com/databricks-industry-solutions/security-analysis-tool/tree/main

  // Solution Accelerator - Audit Logs Alerting (optional):
  enable_audit_log_alerting = false // WARNING: Audit Logs Alerting spins-up jobs and clusters. More information here: https://github.com/andyweaves/system-tables-audit-logs/tree/main/terraform
}