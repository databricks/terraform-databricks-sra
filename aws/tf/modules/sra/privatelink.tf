// EXPLANATION: VPC Gateway Endpoint for S3, Interface Endpoint for Kinesis, and Interface Endpoint for STS


// Skipped in custom operation mode
module "vpc_endpoints" {
  count = var.operation_mode != "custom" ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.sg.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name = "${var.resource_prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = length(module.vpc.intra_subnets) > 0 ? slice(module.vpc.intra_subnets, 0, min(2, length(module.vpc.intra_subnets))) : []
      tags = {
        Name = "${var.resource_prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = length(module.vpc.intra_subnets) > 0 ? slice(module.vpc.intra_subnets, 0, min(2, length(module.vpc.intra_subnets))) : []
      tags = {
        Name = "${var.resource_prefix}-kinesis-vpc-endpoint"
      }
    }
  }
  depends_on = [
    module.vpc
  ]
}

// Skipped in custom operation mode
resource "aws_security_group" "privatelink" {
  count = var.operation_mode != "custom" ? 1 : 0

  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "Inbound rules"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  ingress {
    description     = "Inbound rules"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  ingress {
    description     = "Inbound rules"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  tags = {
    Name = "${var.resource_prefix}-private-link-sg"
  }
}

// Databricks REST endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_rest" {
  count = var.operation_mode != "custom" ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = var.workspace_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink.id]
  subnet_ids          = length(module.vpc.intra_subnets) > 0 ? slice(module.vpc.intra_subnets, 0, min(2, length(module.vpc.intra_subnets))) : []
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-backend-rest"
  }
}

// Databricks SCC endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_relay" {
  count = var.operation_mode != "custom" ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = var.relay_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink.id]
  subnet_ids          = length(module.vpc.intra_subnets) > 0 ? slice(module.vpc.intra_subnets, 0, min(2, length(module.vpc.intra_subnets))) : []
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-backend-relay"
  }
}