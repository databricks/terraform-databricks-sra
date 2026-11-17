variable "sa_name" {
  type        = string
  default     = "databricks-workspace-creator"
  description = "Name of the Google service account to create for Databricks provisioning."
}

variable "project" {
  type    = string
  default = "<my-project-id>"
}

variable "delegate_from" {
  description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
  type        = list(string)
}