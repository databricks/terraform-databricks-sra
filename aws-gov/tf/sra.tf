module "SRA" {
  source = "./modules/sra"
  providers = {
    databricks.mws = databricks.mws
    aws            = aws
  }

  // Common Authentication Variables
  databricks_account_id          = var.databricks_account_id
  client_id                      = var.client_id
  client_secret                  = var.client_secret
  aws_account_id                 = var.aws_account_id
  region                         = var.region
  databricks_gov_shard           = var.databricks_gov_shard
  region_name                    = var.region_name[var.databricks_gov_shard]
  databricks_prod_aws_account_id = var.databricks_prod_aws_account_id[var.databricks_gov_shard]
  uc_master_role_id              = var.uc_master_role_id[var.databricks_gov_shard]
  log_delivery_role_name         = var.log_delivery_role_name[var.databricks_gov_shard]

  // Naming and Tagging Variables:
  resource_prefix = var.resource_prefix

  // Required Variables:
  workspace_catalog_admin                = null             // Workspace catalog admin email.
  user_workspace_admin                   = null             // Workspace admin user email.
  operation_mode                         = "isolated"       // Operation mode (sandbox, custom, firewall, isolated), see README.md for more information.
  workspace_admin_service_principal_name = "sra-example-sp" // Creates an example admin SP for automation use cases.
  metastore_exists                       = false            // If a regional metastore exists set to true. If there are multiple regional metastores, you can comment out "uc_init" and add the metastore ID directly in to the module call for "uc_assignment".

  // AWS Specific Variables:
  cmk_admin_arn                            = null          // CMK admin ARN, defaults to the AWS account root user.
  vpc_cidr_range                           = "10.0.0.0/18" // Please re-define the subsequent subnet ranges if the VPC CIDR range is updated.
  private_subnets_cidr                     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  privatelink_subnets_cidr                 = ["10.0.28.0/26", "10.0.28.64/26", "10.0.28.128/26"]
  availability_zones                       = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  sg_egress_ports                          = [443, 3306, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]
  compliance_security_profile_egress_ports = true // Set to true to enable compliance security profile related egress ports (2443)
  sg_ingress_protocol                      = ["tcp", "udp"]
  sg_egress_protocol                       = ["tcp", "udp"]
  relay_vpce_service                       = var.scc_relay[var.databricks_gov_shard]
  workspace_vpce_service                   = var.workspace[var.databricks_gov_shard]

  // Operation Mode Specific Variables:
  // Sandbox and Firewall Modes
  public_subnets_cidr = ["10.0.29.0/26", "10.0.29.64/26", "10.0.29.128/26"]

  // Firewall Mode Specific:
  firewall_subnets_cidr       = ["10.0.33.0/26", "10.0.33.64/26", "10.0.33.128/26"]
  firewall_allow_list         = [".pypi.org", ".cran.r-project.org", ".pythonhosted.org", ".spark-packages.org", ".maven.org", "maven.apache.org", ".storage-download.googleapis.com"]
  firewall_protocol_deny_list = "IP"
  hive_metastore_fqdn         = var.hms_fqdn[var.databricks_gov_shard] // https://docs.databricks.com/en/resources/supported-regions.html#rds-addresses-for-legacy-hive-metastore

  // Custom Mode Specific:
  custom_vpc_id             = null
  custom_private_subnet_ids = null // List of custom private subnet IDs required.
  custom_sg_id              = null
  custom_relay_vpce_id      = null
  custom_workspace_vpce_id  = null

  // Optional Features:
  enable_read_only_external_location_boolean = false // Set to true to enable a read-only external location.
  read_only_data_bucket                      = null  // S3 bucket name for read-only data.
  read_only_external_location_admin          = null  // Admin for the external location.

  enable_cluster_boolean       = false // Set to true to create a default Databricks clusters.
  enable_admin_configs_boolean = false // Set to true to enable optional admin configurations.
  enable_logging_boolean       = false // Set to true to enable log delivery and creation of related assets (e.g. S3 bucket and IAM role)

  enable_restrictive_root_bucket_boolean      = false // Set to true to enable a restrictive root bucket policy, this is subject to change and may cause unexpected issues in the event of a change.
  enable_restrictive_s3_endpoint_boolean      = false // Set to true to enable a restrictive S3 endpoint policy, this is subject to change and may cause unexpected issues in the event of a change.
  enable_restrictive_sts_endpoint_boolean     = false // Set to true to enable a restrictive STS endpoint policy, this is subject to change and may cause unexpected issues in the event of a change.
  enable_restrictive_kinesis_endpoint_boolean = false // Set to true to enable a restrictive Kinesis endpoint policy, this is subject to change and may cause unexpected issues in the event of a change.

  enable_ip_boolean = false                                   // Set to true to enable IP access list.
  ip_addresses      = ["X.X.X.X", "X.X.X.X/XX", "X.X.X.X/XX"] // Specify IP addresses for access.

  enable_system_tables_schema_boolean = false // Set to true to enable system table schemas (Public Preview).

  enable_sat_boolean        = false // Set to true to enable Security Analysis Tool. https://github.com/databricks-industry-solutions/security-analysis-tool
  enable_audit_log_alerting = false // Set to true to create 40+ queries for audit log alerting based on user activity. https://github.com/andyweaves/system-tables-audit-logs
}