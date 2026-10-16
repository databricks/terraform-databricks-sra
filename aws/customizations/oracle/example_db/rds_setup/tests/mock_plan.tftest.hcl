mock_provider "aws" {}

mock_provider "random" {}

variables {
  allowed_cidr_blocks = ["10.0.0.0/16"]
  region              = "us-east-1"
  resource_prefix     = "sra-test"
  subnet_ids          = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
  vpc_id              = "vpc-0abcd1234efgh5678"
}

# Plans a private, encrypted Oracle instance with automated backups (ARCHIVELOG) and an SSL option exposing TCPS.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = aws_db_instance.oracle.publicly_accessible == false && aws_db_instance.oracle.storage_encrypted == true
    error_message = "The Oracle instance must be private and encrypted at rest."
  }

  assert {
    condition     = aws_db_instance.oracle.backup_retention_period > 0
    error_message = "Automated backups must be enabled so the instance runs in ARCHIVELOG mode."
  }

  assert {
    condition     = one([for o in aws_db_option_group.oracle.option : o.port if o.option_name == "SSL"]) == 2484
    error_message = "The option group must enable the SSL option on the TLS port."
  }

  assert {
    condition     = toset([for i in aws_security_group.oracle.ingress : i.from_port]) == toset([1521, 2484])
    error_message = "The security group must open both the native and TLS listener ports."
  }

  assert {
    condition     = aws_db_instance.oracle.ca_cert_identifier == "rds-ca-rsa4096-g1"
    error_message = "The server certificate CA must be pinned to rds-ca-rsa4096-g1 by default."
  }

  assert {
    condition     = output.ca_bundle_url == "https://truststore.pki.rds.amazonaws.com/us-east-1/us-east-1-bundle.pem"
    error_message = "Commercial regions must point at the regional bundle on the commercial truststore."
  }
}

# GovCloud regions point at the GovCloud truststore.
run "plan_govcloud_ca_bundle_url" {
  command = plan

  variables {
    region = "us-gov-west-1"
  }

  assert {
    condition     = output.ca_bundle_url == "https://truststore.pki.us-gov-west-1.rds.amazonaws.com/us-gov-west-1/us-gov-west-1-bundle.pem"
    error_message = "GovCloud regions must point at the regional bundle on the GovCloud truststore."
  }
}

# Disabling automated backups must be rejected, since CDC requires ARCHIVELOG mode.
run "zero_backup_retention_rejected" {
  command = plan

  variables {
    backup_retention_period = 0
  }

  expect_failures = [
    var.backup_retention_period,
  ]
}

# The DB subnet group needs subnets in at least two AZs.
run "single_subnet_rejected" {
  command = plan

  variables {
    subnet_ids = ["subnet-0abcd1234efgh5678"]
  }

  expect_failures = [
    var.subnet_ids,
  ]
}
