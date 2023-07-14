variable "resource_group_id" {
  type        = string
  description = "(Required) Resource ID of the pre-existing Resource Group that will house Unity Catalog"
}

variable "workspaces_to_associate" {
  type        = list(number)
  description = "(Optional) List of Databricks Workspace IDs to associate with Unity Catalog"
}
