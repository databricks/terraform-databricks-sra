// EXPLANATION: Creates an egress firewall around the dataplane

// Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.resource_prefix}-public-${element(var.availability_zones, count.index)}"
    Project = var.resource_prefix
  }
}

// EIP
resource "aws_eip" "ngw_eip" {
  count  = length(var.public_subnets_cidr)
  domain = "vpc"
}

// NGW
resource "aws_nat_gateway" "ngw" {
  count         = length(var.public_subnets_cidr)
  allocation_id = element(aws_eip.ngw_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name    = "${var.resource_prefix}-ngw-${element(var.availability_zones, count.index)}"
    Project = var.resource_prefix
  }
}

// Private Subnet Route
resource "aws_route" "private" {
  count                  = length(var.private_subnets_cidr)
  route_table_id         = element(var.private_subnet_rt, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
}

// Public RT
resource "aws_route_table" "public_rt" {
  count  = length(var.public_subnets_cidr)
  vpc_id = var.vpc_id
  tags = {
    Name    = "${var.resource_prefix}-public-rt-${element(var.availability_zones, count.index)}"
    Project = var.resource_prefix
  }
}

// Public RT Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)
  depends_on     = [aws_subnet.public]
}

// Firewall Subnet
resource "aws_subnet" "firewall" {
  vpc_id                  = var.vpc_id
  count                   = length(var.firewall_subnets_cidr)
  cidr_block              = element(var.firewall_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.resource_prefix}-firewall-${element(var.availability_zones, count.index)}"
    Project = var.resource_prefix
  }
}

// Firewall RT
resource "aws_route_table" "firewall_rt" {
  count  = length(var.firewall_subnets_cidr)
  vpc_id = var.vpc_id
  tags = {
    Name    = "${var.resource_prefix}-firewall-rt-${element(var.availability_zones, count.index)}"
    Project = var.resource_prefix
  }
}

// Firewall RT Associations
resource "aws_route_table_association" "firewall" {
  count          = length(var.firewall_subnets_cidr)
  subnet_id      = element(aws_subnet.firewall.*.id, count.index)
  route_table_id = element(aws_route_table.firewall_rt.*.id, count.index)
}

// IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name    = "${var.resource_prefix}-igw"
    Project = var.resource_prefix
  }
}

// IGW RT
resource "aws_route_table" "igw_rt" {
  vpc_id = var.vpc_id
  tags = {
    Name    = "${var.resource_prefix}-igw-rt"
    Project = var.resource_prefix
  }
}

// IGW RT Associations
resource "aws_route_table_association" "igw" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.igw_rt.id
}

// Local Map for Availability Zone to Index
locals {
  az_to_index_map = {
    for idx, az in var.availability_zones :
    az => idx
  }

  firewall_endpoints_by_az = {
    for sync_state in aws_networkfirewall_firewall.nfw.firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
  }

  az_to_endpoint_map = {
    for az in var.availability_zones :
    az => lookup(local.firewall_endpoints_by_az, az, null)
  }
}

// Public Route
resource "aws_route" "public" {
  for_each               = local.az_to_endpoint_map
  route_table_id         = aws_route_table.public_rt[local.az_to_index_map[each.key]].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = each.value
  depends_on             = [aws_networkfirewall_firewall.nfw]
}

// Firewall Outbound Route
resource "aws_route" "firewall_outbound" {
  count                  = length(var.firewall_subnets_cidr)
  route_table_id         = element(aws_route_table.firewall_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

// Firewall Inbound Route
resource "aws_route" "firewall_inbound" {
  for_each               = local.az_to_endpoint_map
  route_table_id         = aws_route_table.igw_rt.id
  destination_cidr_block = element(var.public_subnets_cidr, index(var.availability_zones, each.key))
  vpc_endpoint_id        = each.value
  depends_on             = [aws_networkfirewall_firewall.nfw]
}

// FQDN Allow List
resource "aws_networkfirewall_rule_group" "databricks_fqdn_allowlist" {
  capacity = 100
  name     = "${var.resource_prefix}-${var.region}-databricks-fqdn-allowlist"
  type     = "STATEFUL"
  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = var.firewall_allow_list
      }
    }
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.vpc_cidr_range]
        }
      }
    }
  }
  tags = {
    Name    = "${var.resource_prefix}-${var.region}-databricks-fqdn-allowlist"
    Project = var.resource_prefix
  }
}

data "dns_a_record_set" "metastore_dns" {
  host = var.hive_metastore_fqdn[var.databricks_gov_shard]
}

// JDBC Firewall group IP allow list
resource "aws_networkfirewall_rule_group" "databricks_metastore_allowlist" {
  capacity = 100
  name     = "${var.resource_prefix}-${var.region}-databricks-metastore-allowlist"
  type     = "STATEFUL"
  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
    rules_source {
      dynamic "stateful_rule" {
        for_each = toset(data.dns_a_record_set.metastore_dns.addrs)
        content {
          action = "PASS"
          header {
            destination      = stateful_rule.value
            destination_port = 3306
            direction        = "FORWARD"
            protocol         = "TCP"
            source           = "ANY"
            source_port      = "ANY"
          }
          rule_option {
            keyword  = "sid"
            settings = ["1"]
          }
        }
      }
      stateful_rule {
        action = "DROP"
        header {
          destination      = "0.0.0.0/0"
          destination_port = 3306
          direction        = "FORWARD"
          protocol         = "TCP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["2"]
        }
      }
    }
  }
  tags = {
    Name    = "${var.resource_prefix}-${var.region}-databricks-metastore-allowlist"
    Project = var.resource_prefix
  }
}

// Firewall policy
resource "aws_networkfirewall_firewall_policy" "databricks_nfw_policy" {
  name = "${var.resource_prefix}-firewall-policy"

  firewall_policy {

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions           = ["aws:drop_established"]

    stateful_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.databricks_fqdn_allowlist.arn
    }

    stateful_rule_group_reference {
      priority     = 2
      resource_arn = aws_networkfirewall_rule_group.databricks_metastore_allowlist.arn
    }
  }

  tags = {
    Name    = "${var.resource_prefix}-firewall-policy"
    Project = var.resource_prefix
  }
}

// Firewall
resource "aws_networkfirewall_firewall" "nfw" {
  name                = "${var.resource_prefix}-nfw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.databricks_nfw_policy.arn
  vpc_id              = var.vpc_id
  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall[*].id
    content {
      subnet_id = subnet_mapping.value
    }
  }
  tags = {
    Name    = "${var.resource_prefix}-${var.region}-databricks-nfw"
    Project = var.resource_prefix
  }
}