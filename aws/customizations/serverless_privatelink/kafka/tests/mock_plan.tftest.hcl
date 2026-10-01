mock_provider "aws" {}

variables {
  brokers = [
    {
      ip_address = "10.0.20.11"
      name       = "kafka-broker-1"
      nlb_port   = 9001
    },
    {
      ip_address = "10.0.20.12"
      name       = "kafka-broker-2"
      nlb_port   = 9002
    },
  ]
  nlb_subnet_ids  = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
  region          = "us-east-1"
  resource_prefix = "sra-test"
  vpc_id          = "vpc-0abcd1234efgh5678"
}

# Plans an internal NLB with one dedicated TCP listener per broker, each forwarding to that broker's IP on its real
# port, exposed through an endpoint service that requires acceptance and allowlists only the Databricks role.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = aws_lb.kafka.internal == true && aws_lb.kafka.load_balancer_type == "network"
    error_message = "The load balancer must be an internal network load balancer."
  }

  assert {
    condition     = aws_lb_listener.kafka["kafka-broker-1"].port == 9001 && aws_lb_listener.kafka["kafka-broker-2"].port == 9002
    error_message = "Each broker must be advertised on its own NLB listener port."
  }

  assert {
    condition     = aws_lb_target_group_attachment.kafka["kafka-broker-1"].target_id == "10.0.20.11" && aws_lb_target_group_attachment.kafka["kafka-broker-1"].port == 9094
    error_message = "Each broker's listener must forward to that broker's IP on its real port (default 9094)."
  }

  assert {
    condition     = aws_vpc_endpoint_service.kafka.acceptance_required == true
    error_message = "Connections to the endpoint service must require acceptance by default."
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws:iam::565502421330:role/private-connectivity-role-us-east-1"]
    error_message = "Only the regional Databricks serverless private-connectivity role may be allowlisted by default."
  }
}

# The GovCloud civilian shard allowlists the civilian Databricks private-connectivity role.
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

# Brokers sharing an nlb_port would collide on one listener and must be rejected.
run "duplicate_nlb_port_rejected" {
  command = plan

  variables {
    brokers = [
      {
        ip_address = "10.0.20.11"
        name       = "kafka-broker-1"
        nlb_port   = 9001
      },
      {
        ip_address = "10.0.20.12"
        name       = "kafka-broker-2"
        nlb_port   = 9001
      },
    ]
  }

  expect_failures = [
    var.brokers,
  ]
}

# A broker name longer than 28 characters would overflow the 32-character target group name limit.
run "long_broker_name_rejected" {
  command = plan

  variables {
    brokers = [
      {
        ip_address = "10.0.20.11"
        name       = "kafka-broker-with-a-very-long-name"
        nlb_port   = 9001
      },
    ]
  }

  expect_failures = [
    var.brokers,
  ]
}
