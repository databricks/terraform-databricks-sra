# Define a variable to store the title-cased location
locals {
  title_cased_location = title(var.location)

  # Define a map to store service tags with their corresponding values
  service_tags = {
    "sql" : "Sql.${local.title_cased_location}",
    "storage" : "Storage.${local.title_cased_location}",
    "eventhub" : "EventHub.${local.title_cased_location}"
  }
}
