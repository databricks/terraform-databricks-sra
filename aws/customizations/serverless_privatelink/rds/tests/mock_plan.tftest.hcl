mock_provider "aws" {}

variables {
  db_ip_address   = "10.0.30.40"
  db_port         = 5432
  nlb_subnet_ids  = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
  region          = "us-east-1"
  resource_prefix = "sra-test"
  vpc_id          = "vpc-0abcd1234efgh5678"
}

# Plans an internal NLB listening on the database port and forwarding to the RDS private IP, exposed through an
# endpoint service that requires acceptance and allowlists only the Databricks role.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = aws_lb.rds.internal == true && aws_lb.rds.load_balancer_type == "network"
    error_message = "The load balancer must be an internal network load balancer."
  }

  assert {
    condition     = aws_lb_listener.rds.port == 5432 && aws_lb_listener.rds.protocol == "TCP"
    error_message = "The NLB listener must default to the database port over TCP."
  }

  assert {
    condition     = aws_lb_target_group_attachment.rds.target_id == "10.0.30.40" && aws_lb_target_group_attachment.rds.port == 5432
    error_message = "The target group must forward to the RDS private IP on the database port."
  }

  assert {
    condition     = aws_vpc_endpoint_service.rds.acceptance_required == true
    error_message = "Connections to the endpoint service must require acceptance by default."
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws:iam::565502421330:role/private-connectivity-role-us-east-1"]
    error_message = "Only the regional Databricks serverless private-connectivity role may be allowlisted by default."
  }
}

# A separate nlb_port advertises a different port to serverless compute while still forwarding to the database port.
run "plan_custom_nlb_port" {
  command = plan

  variables {
    nlb_port = 15432
  }

  assert {
    condition     = aws_lb_listener.rds.port == 15432 && aws_lb_target_group_attachment.rds.port == 5432
    error_message = "The listener must use nlb_port while the target group keeps forwarding to db_port."
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
