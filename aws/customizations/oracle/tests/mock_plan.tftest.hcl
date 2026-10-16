mock_provider "aws" {}

mock_provider "databricks" {
  alias = "account"
}

mock_provider "databricks" {
  alias = "workspace"
}

variables {
  databricks_account_id     = "00000000-0000-0000-0000-000000000000"
  databricks_workspace_host = "https://example.cloud.databricks.com"
  ncc_id                    = "00000000-0000-0000-0000-000000000001"
  nlb_subnet_ids            = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
  oracle_host               = "mydb.abcdefghijkl.us-east-1.rds.amazonaws.com"
  oracle_ip_address         = "10.0.30.40"
  oracle_password           = uuid() # throwaway value generated per run; no credential is stored in this file
  oracle_service_name       = "ORCL"
  oracle_user               = "DBX_CDC"
  region                    = "us-east-1"
  resource_prefix           = "sra-test"
  server_certificate_path   = "example_db/rds_setup/rds-ca-rsa4096-g1.pem"
  vpc_id                    = "vpc-0abcd1234efgh5678"
}

# Plans an internal NLB on the TCPS port forwarding to the Oracle private IP, exposed through an endpoint service that
# allowlists only the Databricks role, an NCC rule for the Oracle hostname, and a TLS Unity Catalog connection.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = aws_lb.oracle.internal == true && aws_lb.oracle.load_balancer_type == "network"
    error_message = "The load balancer must be an internal network load balancer."
  }

  assert {
    condition     = aws_lb_listener.oracle.port == 2484 && aws_lb_listener.oracle.protocol == "TCP"
    error_message = "The NLB listener must default to the Oracle TCPS port over TCP."
  }

  assert {
    condition     = aws_lb_target_group_attachment.oracle.target_id == "10.0.30.40" && aws_lb_target_group_attachment.oracle.port == 2484
    error_message = "The target group must forward to the Oracle private IP on the TCPS port."
  }

  assert {
    condition     = aws_vpc_endpoint_service.oracle.acceptance_required == false
    error_message = "Connections from the allowlisted role must be auto-accepted by default."
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws:iam::565502421330:role/private-connectivity-role-us-east-1"]
    error_message = "Only the regional Databricks serverless private-connectivity role may be allowlisted by default."
  }

  assert {
    condition     = tolist(databricks_mws_ncc_private_endpoint_rule.oracle.domain_names) == tolist(["mydb.abcdefghijkl.us-east-1.rds.amazonaws.com"])
    error_message = "The NCC private endpoint rule must route the Oracle hostname to the endpoint service."
  }

  assert {
    condition     = databricks_connection.oracle.connection_type == "ORACLE" && databricks_connection.oracle.options["encryption_protocol"] == "TLS"
    error_message = "The Unity Catalog connection must be an Oracle connection over TLS."
  }

  assert {
    condition     = databricks_connection.oracle.options["port"] == "2484" && databricks_connection.oracle.options["service_name"] == "ORCL"
    error_message = "The connection must target the NLB port and the Oracle service name."
  }
}

# A separate nlb_port advertises a different port to serverless compute (and the connection) while still forwarding to
# the Oracle port.
run "plan_custom_nlb_port" {
  command = plan

  variables {
    nlb_port = 12484
  }

  assert {
    condition     = aws_lb_listener.oracle.port == 12484 && aws_lb_target_group_attachment.oracle.port == 2484
    error_message = "The listener must use nlb_port while the target group keeps forwarding to oracle_port."
  }

  assert {
    condition     = databricks_connection.oracle.options["port"] == "12484"
    error_message = "The connection must connect on the advertised NLB port."
  }
}

# GovCloud civilian allowlists the civilian private-connectivity role.
run "plan_govcloud_civilian" {
  command = plan

  variables {
    databricks_gov_shard = "civilian"
    region               = "us-gov-west-1"
  }

  assert {
    condition     = keys(aws_vpc_endpoint_service_allowed_principal.databricks) == ["arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1"]
    error_message = "GovCloud civilian must allowlist the civilian private-connectivity role."
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

# The server certificate must exist, since the connection embeds it.
run "missing_server_certificate_rejected" {
  command = plan

  variables {
    server_certificate_path = "does-not-exist.pem"
  }

  expect_failures = [
    var.server_certificate_path,
  ]
}
