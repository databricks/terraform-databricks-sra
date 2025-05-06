variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "databricks_gov_shard" {
  description = "Databricks Govcloud Shard (civilian or dod)."
  type        = string
}
variable "databricks_prod_aws_account_id" {
<<<<<<< Updated upstream:aws-gov/tf/modules/sra/data_plane_hardening/restrictive_root_bucket/variables.tf
  type = map(string)
=======
  description = "Databricks Govcloud Prod AWS Account ID."
  type        = map(string)
}

variable "region_name" {
  description = "Name of the AWS region."
  type        = string
}

variable "root_s3_bucket" {
  description = "S3 root bucket name for the workspace."
  type        = string
}

variable "workspace_id" {
  description = "workspace ID of deployed workspace."
  type        = string
>>>>>>> Stashed changes:aws-gov/tf/modules/sra/databricks_workspace/restrictive_root_bucket/variables.tf
}