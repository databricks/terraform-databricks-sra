variable "aws_account_id" {
  description = "ID of the AWS account."
  type        = string
}

variable "client_id" {
  description = "Client ID for authentication."
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Secret key for the client ID."
  type        = string
  sensitive   = true
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region code. (e.g. us-east-1)"
  type        = string
  validation {
    condition     = contains(["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-1", "us-east-2", "us-west-2"], var.region)
    error_message = "Valid values for var: region are (ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1, us-east-2, us-west-2)."
  }
}

variable "region_name" {
  description = "Name of the AWS region. (e.g. nvirginia)"
  type        = map(string)
  default = {
    "ap-northeast-1" = "tokyo"
    "ap-northeast-2" = "seoul"
    "ap-south-1"     = "mumbai"
    "ap-southeast-1" = "singapore"
    "ap-southeast-2" = "sydney"
    "ca-central-1"   = "canada"
    "eu-central-1"   = "frankfurt"
    "eu-west-1"      = "ireland"
    "eu-west-2"      = "london"
    "eu-west-3"      = "paris"
    "sa-east-1"      = "saopaulo"
    "us-east-1"      = "nvirginia"
    "us-east-2"      = "ohio"
    "us-west-2"      = "oregon"
    #"us-west-1" = "oregon"
  }
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "workspace" {
  type = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
    #"us-west-1" = ""
  }
}

variable "scc_relay" {
  type = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
    #"us-west-1" = ""
  }
}

variable "hms_fqdn" {
  type = map(string)
  default = {
    "ap-northeast-1" = "mddx5a4bpbpm05.cfrfsun7mryq.ap-northeast-1.rds.amazonaws.com"
    "ap-northeast-2" = "md1915a81ruxky5.cfomhrbro6gt.ap-northeast-2.rds.amazonaws.com"
    "ap-south-1"     = "mdjanpojt83v6j.c5jml0fhgver.ap-south-1.rds.amazonaws.com"
    "ap-southeast-1" = "md1n4trqmokgnhr.csnrqwqko4ho.ap-southeast-1.rds.amazonaws.com"
    "ap-southeast-2" = "mdnrak3rme5y1c.c5f38tyb1fdu.ap-southeast-2.rds.amazonaws.com"
    "ca-central-1"   = "md1w81rjeh9i4n5.co1tih5pqdrl.ca-central-1.rds.amazonaws.com"
    "eu-central-1"   = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
    "eu-west-1"      = "md15cf9e1wmjgny.cxg30ia2wqgj.eu-west-1.rds.amazonaws.com"
    "eu-west-2"      = "mdio2468d9025m.c6fvhwk6cqca.eu-west-2.rds.amazonaws.com"
    "eu-west-3"      = "metastorerds-dbconsolidationmetastore-asda4em2u6eg.c2ybp3dss6ua.eu-west-3.rds.amazonaws.com"
    "sa-east-1"      = "metastorerds-dbconsolidationmetastore-fqekf3pck8yw.cog1aduyg4im.sa-east-1.rds.amazonaws.com"
    "us-east-1"      = "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"
    "us-east-2"      = "md7wf1g369xf22.cluz8hwxjhb6.us-east-2.rds.amazonaws.com"
    "us-west-2"      = "mdpartyyphlhsp.caj77bnxuhme.us-west-2.rds.amazonaws.com"
    "us-west-1"      = "mdzsbtnvk0rnce.c13weuwubexq.us-west-1.rds.amazonaws.com"
  }
}