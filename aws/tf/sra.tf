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

  // Optional CMK admin ARN configuration
  cmk_admin_arn = null // If not required, the root user of the AWS account is used

  // Tags & Naming Variables
  resource_prefix = var.resource_prefix
  resource_owner  = var.resource_owner
  region          = var.region
  region_name     = var.region_name[var.region]

  // Account-level Variables
  metastore_id           = null // Metastore Configuration - leave null if there is no existing regional metastore
  ucname                 = join("", [var.resource_prefix, "-", var.region, "-", "uc"])
  data_bucket            = "< bucket name >"
  data_access_user       = "< user email >"
  enable_logging_boolean = true // Logging Configuration

  // Workspace-level Variables
  dbfsname                 = join("", [var.resource_prefix, "-", var.region, "-", "dbfsroot"])
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

  // Optional - IP Access Lists - Set to True to Enable
  enable_ip_boolean = false
  ip_addresses      = ["X.X.X.X", "X.X.X.X/XX", "X.X.X.X/XX"] // WARNING: Please validate that IPs entered are correct, recommend setting a break glass IP in case of a lockout

  // Optional - Cluster Example - Set to True to Enable
  enable_cluster_boolean = false // WARNING: Clusters will spin-up Databricks clusters and AWS EC2 instances

  // Optional - Security Analysis Tool - Set to True to Enable
  enable_sat_boolean          = false // WARNING: SAT spins-up corresponding jobs and clusters. More information here: https://github.com/databricks-industry-solutions/security-analysis-tool/tree/main
  databricks_account_username = "string"
  databricks_account_password = "string"

  // Optional - Restrictive Root Bucket Configuration - Set to True to Enable
  enable_restrictive_root_bucket_boolean = false // WARNING: Restrictive Root Bucket is frequently updated, but may not take into considerations all new product offerings

  // Optional - AWS Firewall Configuration - Set to True to Enable
  enable_firewall_boolean     = false // WARNING: AWS Network Firewall has an associated uptime charge. More information here: https://aws.amazon.com/network-firewall/pricing/
  firewall_subnets_cidr       = ["10.0.33.0/26", "10.0.33.64/26"]
  firewall_allow_list         = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org", "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"]
  firewall_protocol_deny_list = "ICMP,FTP,SSH"
}
