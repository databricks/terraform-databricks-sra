locals {
  # The public_repos variable is used here to mirror firewall rules between classic and serverless for the spokes
  spoke_internet_allowed_domains = [for dest in var.public_repos : dest if !startswith(dest, "*.")]
  spoke_internet_allowed_destinations = [
    for dest in local.spoke_internet_allowed_domains :
    {
      destination               = trimprefix(dest, "*."),
      internet_destination_type = "DNS_NAME"
    }
  ]

  # The hub_allowed_urls variable is used here to allow for hub to have a different allow list (primarily for SAT)
  hub_internet_allowed_domains = [for dest in var.hub_allowed_urls : dest if !startswith(dest, "*.")]
  hub_internet_allowed_destinations = [
    for dest in local.hub_internet_allowed_domains :
    {
      destination               = trimprefix(dest, "*."),
      internet_destination_type = "DNS_NAME"
    }
  ]

  # We use this to make sure that if we provision the 10th NCC in a region, that it does not cause subsequent terraform
  # plans/applies to fail due to the precondition on the NCC resource.
  ncc_name             = "ncc-${var.location}-${var.resource_suffix}"
  current_ncc_count    = length([for k in data.databricks_mws_network_connectivity_configs.this.names : k if k != local.ncc_name])
  ncc_region_limit     = 10
  title_cased_location = title(var.location)

  # Define a map to store service tags with their corresponding values
  service_tags = {
    "sql"      = "Sql.${local.title_cased_location}",
    "storage"  = "Storage.${local.title_cased_location}",
    "eventhub" = "EventHub.${local.title_cased_location}"
  }
}
