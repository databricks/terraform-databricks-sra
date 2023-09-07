module "SRA" {
  source = "./modules/sra"
  providers = {
    databricks.mws = databricks.mws
    aws            = aws
  }

  // Regional parameters for PrivateLink and optional metastore FQDN: https://docs.databricks.com/en/resources/supported-regions.html
  // Authentication Variables
  databricks_account_id = var.databricks_account_id
  client_id             = var.client_id
  client_secret         = var.client_secret
  aws_account_id        = var.aws_account_id

  // Tags & Naming Variables
  resource_prefix = var.resource_prefix
  resource_owner  = var.resource_owner
  region          = var.region
  region_name     = var.region_name

  // Account-level Variables
  // Metastore Configuration - leave null if there is no existing regional metastore
  metastore_id = null
  ucname       = join("", [var.resource_prefix, "-", var.region, "-", "uc"])
  data_bucket  = "<bucket name>"
  data_access  = "<identity like user or group>"

  // Logging Configuration - set to false if no logging configuration exists
  enable_logging_boolean = false

  // Workspace-level Variables
  dbfsname                 = join("", [var.resource_prefix, "-", var.region, "-", "dbfsroot"])
  vpc_cidr_range           = "10.0.0.0/18"
  private_subnets_cidr     = ["10.0.16.0/22", "10.0.24.0/22"]
  privatelink_subnets_cidr = ["10.0.32.0/26", "10.0.32.64/26"]
  public_subnets_cidr      = ["10.0.32.128/26", "10.0.32.192/26"]
  availability_zones       = ["us-east-1a", "us-east-1b"]
  sg_egress_ports          = [443, 3306, 6666]
  sg_ingress_protocol      = ["tcp", "udp"]
  sg_egress_protocol       = ["tcp", "udp"]
  relay_vpce_service       = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
  workspace_vpce_service   = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"

  // Ip Access Lists - disabled by default, set to appropriate corporate egress IPs if enabled
  ip_addresses = ["1.1.1.1", "1.2.3.0/24", "1.2.5.0/24"]

  // AWS Firewall - set to true if you'd like to create an egress AWS Network Firewall
  // WARNING: This product does incur uptime charges
  enable_firewall_boolean     = false
  firewall_subnets_cidr       = ["10.0.33.0/26", "10.0.33.64/26"]
  firewall_allow_list         = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org", "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"]
  firewall_protocol_deny_list = "ICMP,FTP,SSH"

  // Restrictive Root Bucket - set to true if you'd like to restrict the workspace root bucket
  // WARNING: The restrictive root bucket is updated occassionally, however, this is no guarantee on full functionality with new workspace functionality
  enable_restrictive_root_bucket_boolean = true

}