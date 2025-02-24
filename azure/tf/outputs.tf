output "hub_network_subnets" {
  description = "Subnets created in the hub network"
  value       = module.subnet_addrs.network_cidr_blocks
}
