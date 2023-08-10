# VNet
# subnets
# workspace
# private endpoint(s)/service endpoints
# route table
# security group
locals {
  prefix               = "${var.project_name}-${var.environment}"
  title_cased_location = title(var.location)
  service_tags = {
    "databricks" : "AzureDatabricks",
    "sql" : "Sql.${local.title_cased_location}",
    "storage" : "Storage.${local.title_cased_location}",
    "eventhub" : "EventHub.${local.title_cased_location}"
  }
}
