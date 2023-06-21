module "SRA" {
    source = "./modules/sra"
    providers = {
      databricks.mws                = databricks.mws
      aws                           = aws
    }
  
   resource_prefix              = var.resource_prefix
   resource_owner               = var.resource_owner
   databricks_account_id        = var.databricks_account_id
   databricks_account_username  = var.databricks_account_username
   databricks_account_password  = var.databricks_account_password
   aws_account_id               = var.aws_account_id
   region                       = var.region

   vpc_cidr_range               = "10.0.0.0/18"

   // Initial two private subnets are for workspace subnets, latter two are for VPC Interface Endpoints (Databricks (SCC + Relay), Kinesis, and STS)
   private_subnets_cidr         = ["10.0.16.0/22", "10.0.24.0/22", "10.0.32.0/26", "10.0.32.64/26"]
   public_subnets_cidr          = ["10.0.32.128/26", "10.0.32.192/26"]
   availability_zones           = ["us-east-1a", "us-east-1b"]

   // VPC services for you region can be found here: https://docs.databricks.com/resources/supported-regions.html#control-plane-nat-and-storage-bucket-addresses
   relay_vpce_service           = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
   workspace_vpce_service       = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
   sg_egress_ports              = [443, 3306, 6666]
   sg_ingress_protocol          = ["tcp", "udp"]
   sg_egress_protocol           = ["tcp", "udp"]

   // Create an example storage credential and IAM role with read only access to this bucket 
   data_bucket                  = "delta-lake-oss-emr-demo"
   dbfsname                     = join("", [var.resource_prefix, "-", var.region, "-", "dbfsroot"]) 
   ucname                       = join("", [var.resource_prefix, "-", var.region, "-", "uc"]) 
}