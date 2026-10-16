# Example Oracle database: RDS setup (Amazon RDS for Oracle)

> **For testing only.** The [oracle customization](../../oracle.md) assumes you already have the Oracle database you want to connect to. Use this folder only to stand up a throwaway source for exercising it end to end.

Standalone Terraform root that creates an **Amazon RDS for Oracle** instance configured the way the parent customization and Lakeflow Connect CDC expect:

| Resource | Purpose |
|----------|---------|
| `aws_db_instance.oracle` | Oracle SE2 (license-included), gp3, encrypted, private. Automated backups enabled, so the instance runs in ARCHIVELOG mode. |
| `aws_db_option_group.oracle` | `SSL` option: TCPS listener on `tls_port` (`2484`) with `SQLNET.SSL_VERSION = 1.2`, required by Compliance Security Profile workspaces. |
| `aws_db_subnet_group.oracle` | DB subnet group across the supplied subnets. |
| `aws_security_group.oracle` | Ingress on `1521` (native) and `2484` (TLS) from `allowed_cidr_blocks` and `allowed_security_group_ids`. |
| `random_password.master` | Generated master password. |

The instance's server certificate CA is pinned with `ca_cert_identifier` (default `rds-ca-rsa4096-g1`). `rds-ca-rsa4096-g1.pem` is the **public** Amazon RDS CA chain for that CA in `us-gov-west-1`. RDS CAs are per region, so for any other region download the regional bundle from the `ca_bundle_url` output instead (see the [RDS SSL documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html)):

```bash
curl -o rds-ca.pem "$(terraform output -raw ca_bundle_url)"
```

## Usage

```bash
cp template.tfvars.example terraform.tfvars
# edit terraform.tfvars: region, resource_prefix, vpc_id, subnet_ids, allowed_cidr_blocks

terraform init
terraform apply -var-file=terraform.tfvars
```

Then feed the outputs into the parent customization:

| Output | Parent variable |
|--------|-----------------|
| `oracle_host` | `oracle_host` |
| `oracle_service_name` | `oracle_service_name` |
| `tls_port` | `oracle_port` |
| result of `private_ip_lookup_command` | `oracle_ip_address` |
| file downloaded from `ca_bundle_url` (or `rds-ca-rsa4096-g1.pem` in us-gov-west-1) | `server_certificate_path` |

Before applying the parent with a dedicated CDC user, run the [`cdc_setup`](../../oracle.md#cdc-ingestion-lakeflow-connect) notebooks as the master user (`master_username` / `terraform output -raw master_password`). To load sample data, then run [`../test_data_setup/create_sample_table_notebook.py`](../test_data_setup/create_sample_table_notebook.py).

## Notes

- `allowed_cidr_blocks` must include the subnet CIDRs of the parent customization's NLB (`nlb_subnet_ids`), or the target group reports unhealthy.
- Terraform state holds the generated master password in plaintext. Destroy the instance when you're done testing.
- `skip_final_snapshot = true` and `deletion_protection = false` by default, so `terraform destroy` removes the instance without a snapshot.
