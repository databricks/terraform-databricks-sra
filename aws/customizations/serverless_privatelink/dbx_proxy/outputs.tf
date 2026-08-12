output "vpc_endpoint_service_name" {
  description = "Name of the VPC endpoint service (com.amazonaws.vpce.<region>.vpce-svc-xxxx). Add this to the SRA serverless_private_endpoint_rules variable to register it with the Databricks NCC, then accept the pending connection on the endpoint service."
  value       = module.dbx_proxy.load_balancer.vpc_endpoint_service_name
}

output "load_balancer" {
  description = "dbx-proxy load balancer outputs: nlb_arn, nlb_dns_name, nlb_target_group_arns, nlb_security_group_ids, vpc_endpoint_service_arn, vpc_endpoint_service_name."
  value       = module.dbx_proxy.load_balancer
}

output "networking" {
  description = "dbx-proxy networking outputs: vpc_id, vpc_cidr, subnet_ids, subnet_cidrs, nat_gateway_id, nat_subnet_id, nat_subnet_cidr, internet_gateway_id."
  value       = module.dbx_proxy.networking
}

output "proxy" {
  description = "dbx-proxy fleet outputs: iam_role_name, iam_role_arn, instance_profile_name, instance_profile_arn, security_group_id, autoscaling_group_name, launch_template_name, dbx_proxy_cfg."
  value       = module.dbx_proxy.proxy
}
