# The dbx-proxy module configures its own aws provider, which mock_provider cannot replace, so the module is
# overridden here and these tests cover this wrapper: its variable validations and output wiring.
override_module {
  target = module.dbx_proxy
  outputs = {
    load_balancer = {
      vpc_endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-0123456789abcdef0"
    }
    networking = {}
    proxy      = {}
  }
}

variables {
  dbx_proxy_listener = [
    {
      mode = "tcp"
      name = "postgres"
      port = 5432
      routes = [
        {
          destinations = [
            {
              host = "db.internal.example.com"
              name = "primary"
              port = 5432
            },
          ]
          domains = []
          name    = "default"
        },
      ]
    },
  ]
  region          = "us-east-1"
  resource_prefix = "sra-test"
}

# Plans the default bootstrap deployment and exposes the endpoint service name that is registered with the NCC.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = output.vpc_endpoint_service_name == "com.amazonaws.vpce.us-east-1.vpce-svc-0123456789abcdef0"
    error_message = "vpc_endpoint_service_name must expose the dbx-proxy endpoint service name."
  }
}

# us-gov-west-1 without a GovCloud shard must be rejected, since the allowlisted role depends on the shard.
run "govcloud_without_shard_rejected" {
  command = plan

  variables {
    region = "us-gov-west-1"
  }

  expect_failures = [
    var.databricks_gov_shard,
  ]
}

# An unknown GovCloud shard must be rejected.
run "invalid_gov_shard_rejected" {
  command = plan

  variables {
    databricks_gov_shard = "secret"
  }

  expect_failures = [
    var.databricks_gov_shard,
  ]
}

# Only the bootstrap and proxy-only deployment modes are supported.
run "invalid_deployment_mode_rejected" {
  command = plan

  variables {
    deployment_mode = "standalone"
  }

  expect_failures = [
    var.deployment_mode,
  ]
}
