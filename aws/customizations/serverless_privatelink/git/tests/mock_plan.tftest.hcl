mock_provider "aws" {}

variables {
  git_ip_address  = "10.0.10.25"
  git_ports       = [22, 443]
  nlb_subnet_ids  = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
  region          = "us-east-1"
  resource_prefix = "sra-test"
  vpc_id          = "vpc-0abcd1234efgh5678"
}

# Plans an internal NLB with one TCP listener and IP target group per Git port, all forwarding to the Git server,
# exposed through an endpoint service that requires acceptance and allowlists only the Databricks role.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = aws_lb.git.internal == true && aws_lb.git.load_balancer_type == "network"
    error_message = "The load balancer must be an internal network load balancer."
  }

  assert {
    condition     = toset(keys(aws_lb_listener.git)) == toset(["22", "443"]) && alltrue([for l in aws_lb_listener.git : l.protocol == "TCP"])
    error_message = "There must be one TCP listener per Git port."
  }

  assert {
    condition     = alltrue([for a in aws_lb_target_group_attachment.git : a.target_id == "10.0.10.25"])
    error_message = "Every target group must forward to the Git server's private IP."
  }

  assert {
    condition     = aws_vpc_endpoint_service.git.acceptance_required == true
    error_message = "Connections to the endpoint service must require acceptance by default."
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws:iam::565502421330:role/private-connectivity-role-us-east-1"]
    error_message = "Only the regional Databricks serverless private-connectivity role may be allowlisted by default."
  }
}

# The GovCloud DoD shard allowlists the DoD Databricks private-connectivity role.
run "plan_govcloud_dod" {
  command = plan

  variables {
    databricks_gov_shard = "dod"
    region               = "us-gov-west-1"
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1"]
    error_message = "The GovCloud DoD shard must allowlist the DoD Databricks private-connectivity role."
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

# Duplicate Git ports would create conflicting listeners and must be rejected.
run "duplicate_git_ports_rejected" {
  command = plan

  variables {
    git_ports = [443, 443]
  }

  expect_failures = [
    var.git_ports,
  ]
}

# The NLB needs at least one subnet.
run "empty_nlb_subnets_rejected" {
  command = plan

  variables {
    nlb_subnet_ids = []
  }

  expect_failures = [
    var.nlb_subnet_ids,
  ]
}
