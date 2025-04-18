module "sra" {
  source = "./modules/sra"
  providers = {
    databricks.mws = databricks.mws
    aws            = aws
  }

  databricks_account_id          = var.databricks_account_id
  client_id                      = var.client_id
  client_secret                  = var.client_secret
  aws_account_id                 = var.aws_account_id
  region                         = var.region
  region_name                    = var.region_name[var.databricks_gov_shard]
  region_bucket_name             = var.region_bucket_name[var.databricks_gov_shard]
  databricks_gov_shard           = var.databricks_gov_shard
  admin_user                     = var.admin_user
  resource_prefix                = var.resource_prefix

  # REQUIRED:
  network_configuration          = "isolated" // Network (custom or isolated), see README.md for more information.
  metastore_exists               = false      // If a regional metastore exists set to true.

  # REQUIRED IF USING ISOLATED NETWORK:
  vpc_cidr_range                           = "10.0.0.0/18" // Please re-define the subsequent subnet ranges if the VPC CIDR range is updated.
  private_subnets_cidr                     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  privatelink_subnets_cidr                 = ["10.0.28.0/26", "10.0.28.64/26", "10.0.28.128/26"]
  availability_zones                       = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  sg_egress_ports                          = [443, 2443, 3306, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]

  # REQUIRED IF USING NON-ROOT ACCOUNT CMK ADMIN:
  # cmk_admin_arn             = "arn:aws-us-gov:iam::123456789012:user/CMKAdmin" // Example CMK ARN

  # REQUIRED IF USING CUSTOM NETWORK:
  # custom_vpc_id             = "vpc-0abc123456def7890" // Example VPC ID
  # custom_private_subnet_ids = ["subnet-0123456789abcdef0", "subnet-0abcdef1234567890"] // Example private subnet IDs
  # custom_sg_id              = "sg-0123456789abcdef0" // Example security group ID
  # custom_relay_vpce_id      = "vpce-0abc123456def7890" // Example PrivateLink endpoint ID for Databricks relay
  # custom_workspace_vpce_id  = "vpce-0abcdef1234567890" // Example PrivateLink endpoint ID for Databricks workspace

  # OPTIONAL - ENABLE SECURITY ANALYSIS TOOL:
  enable_security_analysis_tool = true

  # OPTIONAL - DEPLOYMENT NAME:
  deployment_name = null // Deployment name for the workspace. Must first be enabled by a Databricks representative.
}