output "hub_network_subnets" {
  value = module.subnet_addrs.network_cidr_blocks
}

# output "ipgroup_cidrs" {
#   value = module.spoke[*].ipgroup_cidrs
# }
