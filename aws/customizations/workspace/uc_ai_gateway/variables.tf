variable "bedrock_provider_service" {
  description = "Optional AWS Bedrock model-provider service configuration. Authentication uses an existing UC service credential so no provider secret is stored in Terraform state."
  type = object({
    allow_all_targets = optional(bool, false)
    comment           = optional(string, null)
    id                = string
    rate_limits = optional(list(object({
      key               = string
      principal         = optional(string)
      renewal_period    = string
      request_tag_key   = optional(string)
      request_tag_value = optional(string)
      requests          = optional(number)
      tokens            = optional(number)
    })), [])
    region                  = string
    service_credential_name = string
    targets = optional(list(object({
      model            = string
      native_api_types = optional(list(string), [])
    })), [])
  })
  default = null

  validation {
    condition     = try(length(trimspace(var.bedrock_provider_service.id)) > 0, true)
    error_message = "bedrock_provider_service.id must not be empty."
  }

  validation {
    condition     = try(length(trimspace(var.bedrock_provider_service.service_credential_name)) > 0, true)
    error_message = "bedrock_provider_service.service_credential_name must not be empty."
  }
}

variable "catalog_name" {
  description = "Unity Catalog catalog containing the parent schema for AI Gateway securables."
  type        = string
}

variable "mcp_service" {
  description = "Optional MCP service configuration backed by an existing Unity Catalog connection."
  type = object({
    comment                = optional(string, null)
    id                     = string
    include_tool_selectors = optional(list(string), [])
    rate_limits = optional(list(object({
      key               = string
      principal         = optional(string)
      renewal_period    = string
      request_tag_key   = optional(string)
      request_tag_value = optional(string)
      requests          = optional(number)
      tokens            = optional(number)
    })), [])
    source_connection_name = string
  })
  default = null

  validation {
    condition     = try(startswith(var.mcp_service.source_connection_name, "connections/"), true)
    error_message = "mcp_service.source_connection_name must use the resource-name format connections/{name}."
  }
}

variable "model_service" {
  description = "Optional model service routed through the Bedrock provider service created by this customization."
  type = object({
    comment = optional(string, null)
    destinations = list(object({
      model              = string
      name               = string
      native_api_types   = optional(list(string), [])
      traffic_percentage = number
    }))
    id = string
    rate_limits = optional(list(object({
      key               = string
      principal         = optional(string)
      renewal_period    = string
      request_tag_key   = optional(string)
      request_tag_value = optional(string)
      requests          = optional(number)
      tokens            = optional(number)
    })), [])
  })
  default = null

  validation {
    condition = try(alltrue([
      for destination in var.model_service.destinations :
      destination.traffic_percentage >= 0 && destination.traffic_percentage <= 100 && floor(destination.traffic_percentage) == destination.traffic_percentage
    ]), true)
    error_message = "Each model_service traffic_percentage must be an integer from 0 through 100."
  }
}

variable "owner" {
  description = "Optional owner assigned to each enabled UC AI Gateway securable."
  type        = string
  default     = null
}

variable "schema_name" {
  description = "Unity Catalog schema containing the AI Gateway securables."
  type        = string
}
