mock_provider "aws" {}

variables {
  nlb_subnet_ids                 = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
  region                         = "us-east-1"
  resource_prefix                = "sra-test"
  s3_endpoint_security_group_ids = ["sg-0abcd1234efgh5678"]
  s3_endpoint_subnet_ids         = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
  vpc_id                         = "vpc-0abcd1234efgh5678"
}

# Plans the commercial configuration: an S3 interface endpoint with private DNS off, fronted by an internal NLB on
# TCP 443, exposed through an endpoint service that requires acceptance and allowlists only the Databricks role.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = aws_vpc_endpoint.s3.vpc_endpoint_type == "Interface" && aws_vpc_endpoint.s3.service_name == "com.amazonaws.us-east-1.s3"
    error_message = "The S3 endpoint must be an interface endpoint for the regional S3 service."
  }

  assert {
    condition     = aws_vpc_endpoint.s3.private_dns_enabled == false
    error_message = "Private DNS must be disabled on the S3 interface endpoint because it is fronted by the NLB."
  }

  assert {
    condition     = aws_lb.s3.internal == true && aws_lb.s3.load_balancer_type == "network"
    error_message = "The load balancer must be an internal network load balancer."
  }

  assert {
    condition     = aws_lb_listener.s3.port == 443 && aws_lb_listener.s3.protocol == "TCP"
    error_message = "The NLB listener must pass TLS through on TCP 443."
  }

  assert {
    condition     = aws_vpc_endpoint_service.s3.acceptance_required == true
    error_message = "Connections to the endpoint service must require acceptance by default."
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws:iam::565502421330:role/private-connectivity-role-us-east-1"]
    error_message = "Only the regional Databricks serverless private-connectivity role may be allowlisted by default."
  }
}

# GovCloud civilian and DoD shards each allowlist their own Databricks private-connectivity role.
run "plan_govcloud_civilian" {
  command = plan

  variables {
    databricks_gov_shard = "civilian"
    region               = "us-gov-west-1"
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1"]
    error_message = "The GovCloud civilian shard must allowlist the civilian Databricks private-connectivity role."
  }
}

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

# The NLB and the S3 interface endpoint each need at least one subnet.
run "empty_subnets_rejected" {
  command = plan

  variables {
    nlb_subnet_ids         = []
    s3_endpoint_subnet_ids = []
  }

  expect_failures = [
    var.nlb_subnet_ids,
    var.s3_endpoint_subnet_ids,
  ]
}
