mock_provider "databricks" {}

variables {
  endpoint_rate_limit_calls = 100
  excluded_endpoint_names   = ["legacy-endpoint"]
}

# Plans the enforced rate-limit configuration. The mocked provider cannot populate the nested endpoints attribute of
# databricks_serving_endpoints (Terraform rejects any mock or override value for it), so the per-endpoint filtering
# is not exercised here; the run checks the enforced settings and the excluded endpoint list instead.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = terraform_data.configuration.input.rate_limit_calls == 100 && terraform_data.configuration.input.renewal_period == "minute"
    error_message = "The configured per-minute rate limit must be enforced."
  }

  assert {
    condition     = toset(output.excluded_endpoint_names) == toset(["legacy-endpoint"])
    error_message = "Excluded endpoints must be reported so they can be reviewed."
  }
}

# A zero-call limit blocks all traffic, so it is rejected unless allow_zero_calls confirms the shutdown.
run "zero_calls_without_confirmation_rejected" {
  command = plan

  variables {
    endpoint_rate_limit_calls = 0
  }

  expect_failures = [
    terraform_data.configuration,
  ]
}

# A zero-call limit is allowed once allow_zero_calls confirms the intentional shutdown.
run "plan_zero_calls_confirmed" {
  command = plan

  variables {
    allow_zero_calls          = true
    endpoint_rate_limit_calls = 0
  }
}

# Negative or fractional call limits must be rejected.
run "invalid_rate_limit_calls_rejected" {
  command = plan

  variables {
    endpoint_rate_limit_calls = 1.5
  }

  expect_failures = [
    var.endpoint_rate_limit_calls,
  ]
}

# Only the minute renewal period is supported by the AI Gateway API.
run "invalid_renewal_period_rejected" {
  command = plan

  variables {
    endpoint_rate_limit_renewal_period = "hour"
  }

  expect_failures = [
    var.endpoint_rate_limit_renewal_period,
  ]
}

# An empty enforcement revision must be rejected.
run "empty_enforcement_revision_rejected" {
  command = plan

  variables {
    enforcement_revision = " "
  }

  expect_failures = [
    var.enforcement_revision,
  ]
}
