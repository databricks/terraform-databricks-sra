output "ca_bundle_url" {
  description = "URL of the regional Amazon RDS CA bundle that verifies the instance's server certificate. Download it (curl -o rds-ca.pem <url>) and pass the file as server_certificate_path to the oracle customization. In us-gov-west-1 the bundled rds-ca-rsa4096-g1.pem also works."
  value = startswith(var.region, "us-gov-") ? (
    "https://truststore.pki.us-gov-west-1.rds.amazonaws.com/${var.region}/${var.region}-bundle.pem"
  ) : "https://truststore.pki.rds.amazonaws.com/${var.region}/${var.region}-bundle.pem"
}

output "jdbc_url" {
  description = "Oracle thin-driver JDBC URL over TCPS (TLS), e.g. for a JDBC fallback from classic compute."
  value       = "jdbc:oracle:thin:@tcps://${aws_db_instance.oracle.address}:${var.tls_port}/${var.db_name}"
}

output "master_password" {
  description = "Generated master password for the Oracle instance."
  value       = random_password.master.result
  sensitive   = true
}

output "master_username" {
  description = "Master username for the Oracle instance. Use it to run the cdc_setup notebooks, not for the Unity Catalog connection."
  value       = var.master_username
}

output "oracle_host" {
  description = "DNS address of the Oracle RDS instance. Pass as oracle_host to the parent oracle customization."
  value       = aws_db_instance.oracle.address
}

output "oracle_service_name" {
  description = "Oracle service name. Pass as oracle_service_name to the parent oracle customization."
  value       = var.db_name
}

output "private_ip_lookup_command" {
  description = "AWS CLI command that prints the instance's private IP. Pass the result as oracle_ip_address to the parent oracle customization."
  value       = "aws ec2 describe-network-interfaces --region ${var.region} --filters Name=group-id,Values=${aws_security_group.oracle.id} --query 'NetworkInterfaces[].PrivateIpAddress' --output text"
}

output "security_group_id" {
  description = "Security group ID protecting the Oracle instance."
  value       = aws_security_group.oracle.id
}

output "tls_port" {
  description = "Oracle TCPS (TLS) listener port. Pass as oracle_port to the parent oracle customization."
  value       = var.tls_port
}
