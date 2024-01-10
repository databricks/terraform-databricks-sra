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
  enable_logging_boolean = false // Logging configuration - set to false if a logging configuration currently exists
  user_workspace_access  = ""

  // Account - Unity Catalog:
  metastore_id     = null // Metastore configuration - leave null if there is no existing regional metastore
  ucname           = join("", [var.resource_prefix, "-", var.region, "-", "uc"])
  data_bucket      = "jd-test-bucket"
  user_data_access = "jd.braun+awspsa@databricks.com"

  // Workspace - operation mode:
  operation_mode = "standard" // Accepted values: standard, custom, firewall, or isolated

  // Workspace - AWS non-networking variables:
  dbfsname                         = join("", [var.resource_prefix, "-", var.region, "-", "dbfsroot"])
  cmk_admin_arn                    = null  // If not provided, the root user of the AWS account is used
  enable_cluster_boolean           = false // WARNING: Clusters will spin-up Databricks clusters and AWS EC2 instances
  workspace_service_principal_name = "sra-example-sp"

  // Workspace - networking variables (optional if using custom operation mode):
  vpc_cidr_range           = "10.0.0.0/18"
  private_subnets_cidr     = ["10.0.16.0/22", "10.0.24.0/22"]
  privatelink_subnets_cidr = ["10.0.32.0/26", "10.0.32.64/26"]
  public_subnets_cidr      = ["10.0.32.128/26", "10.0.32.192/26"]
  availability_zones       = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  sg_egress_ports          = [443, 2443, 3306, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]
  sg_ingress_protocol      = ["tcp", "udp"]
  sg_egress_protocol       = ["tcp", "udp"]
  relay_vpce_service       = var.scc_relay[var.region]
  workspace_vpce_service   = var.workspace[var.region]

  // Workspace - networking variables (required if using custom operation mode):
  custom_vpc_id             =  null
  custom_private_subnet_ids =  null // list of strings required
  custom_sg_id              =  null 
  custom_relay_vpce_id      =  null
  custom_workspace_vpce_id  =  null

  // Workspace - networking variables (required if using firewall operation mode):
  firewall_subnets_cidr       = ["10.0.33.0/26", "10.0.33.64/26"]
  firewall_allow_list         = [".pypi.org", ".cran.r-project.org", ".pythonhosted.org"]
  firewall_protocol_deny_list = "IP"
  hive_metastore_fqdn         = "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"

  // Workspace - restrictive AWS asset policies (optional):
  enable_restrictive_root_bucket_boolean      = false
  enable_restrictive_s3_endpoint_boolean      = false
  enable_restrictive_sts_endpoint_boolean     = false
  enable_restrictive_kinesis_endpoint_boolean = false

  // Workspace - additional security features (optional): 
  enable_ip_boolean = false
  ip_addresses      = ["X.X.X.X", "X.X.X.X/XX", "X.X.X.X/XX"] // WARNING: Please validate that IPs entered are correct, recommend setting a break glass IP in case of a lockout

  enable_sat_boolean          = false // WARNING: Security analysis tool spins-up jobs and clusters. More information here: https://github.com/databricks-industry-solutions/security-analysis-tool/tree/main
  databricks_account_username = "string"
  databricks_account_password = "string"
}
