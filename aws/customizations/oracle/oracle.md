# Oracle: Serverless PrivateLink and Unity Catalog connection

Terraform **customization** that connects an **existing Oracle database** in your AWS network to a Databricks workspace for [Lakehouse Federation](https://docs.databricks.com/aws/en/query-federation/oracle) and [Lakeflow Connect Oracle CDC ingestion](https://docs.databricks.com/aws/en/ingestion/lakeflow-connect/oracle), including the serverless PrivateLink path and the TLS requirement of the Compliance Security Profile (CSP). Works across environments: the allowlisted role and the Databricks account host are selected automatically from `region` (commercial vs GovCloud) and, for GovCloud, `databricks_gov_shard` (civilian vs DoD).

This customization is self-contained and does **not** touch the main SRA workspace deployment under [`aws/tf`](../../tf). It creates:

- **Step 1: Network Load Balancer.** An internal-scheme NLB in your VPC that fronts the Oracle TCPS (TLS) listener over TCP. A single `ip` target group forwards to the database's private IP and `oracle_port`, and one listener advertises the database to serverless compute on `nlb_port` (defaults to `oracle_port`).
- **Step 2: VPC endpoint service.** A VPC endpoint service (powered by AWS PrivateLink) over the NLB with the **Databricks serverless private-connectivity role** allowlisted. These are steps 1 and 2 of [Configure private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network).
- **NCC private endpoint rule.** A rule on the workspace's existing Network Connectivity Configuration (the one the main SRA config creates and binds) that routes `oracle_host` to the endpoint service.
- **Unity Catalog connection and foreign catalog.** A `TYPE ORACLE` connection over TLS, plus a foreign catalog on top of it.

```
Serverless ─▶ NCC private endpoint rule ─▶ VPC endpoint service ─▶ internal NLB ─▶ Oracle (TCPS/TLS 2484)
```

Classic compute in the workspace VPC connects to the database **directly** (no NLB); its security group needs egress to the database on `oracle_port`, and the database security group needs matching ingress.

The folder also contains:

| Folder | Purpose |
|--------|---------|
| [`cdc_setup`](#cdc-ingestion-lakeflow-connect) | Helper notebooks and SQL that prepare your Oracle database for Lakeflow Connect CDC and troubleshoot connectivity. Needed for CDC ingestion whether or not you use `example_db`. |
| [`example_db`](example_db/example_db.md) | **Testing only.** An example Oracle source for exercising this customization end to end when you don't already have one: [`rds_setup`](example_db/rds_setup/rds_setup.md) stands up an Amazon RDS for Oracle instance with a TLS listener, and `test_data_setup` creates a sample CDC source table. |

## Databricks serverless private-connectivity role

The allowlisted principal is selected automatically from `region` and `databricks_gov_shard`:

| Environment | Condition | Role ARN |
|-------------|-----------|----------|
| AWS commercial | any non-GovCloud region | `arn:aws:iam::565502421330:role/private-connectivity-role-<region>` |
| AWS GovCloud (Civilian) | `region = us-gov-west-1`, `databricks_gov_shard = civilian` | `arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1` |
| AWS GovCloud (DoD) | `region = us-gov-west-1`, `databricks_gov_shard = dod` | `arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1` |

`databricks_gov_shard` defaults to `null` and is ignored for commercial regions, but is **required** when `region = us-gov-west-1`. Terraform errors out at plan time if it is unset there, so a GovCloud deployment can't silently allowlist the wrong role. Set `allowed_principals = ["*"]` to use the simplified allow-all approach from the docs instead.

## Prerequisites

- An Oracle database reachable from `vpc_id`, with a **TCPS (TLS) listener**. On Amazon RDS for Oracle, add the `SSL` option to the instance's option group (port `2484`, `SQLNET.SSL_VERSION = 1.2`); see [`example_db/rds_setup/main.tf`](example_db/rds_setup/main.tf) for an example.
- The database security group allows inbound `oracle_port` from the `nlb_subnet_ids` CIDRs (an internal NLB sources traffic from its nodes' private IPs). Without this the target group reports unhealthy and the connection fails.
- The PEM CA chain that signed the Oracle server certificate. For Amazon RDS, download the [regional RDS CA bundle](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html); the us-gov-west-1 `rds-ca-rsa4096-g1` chain is included at [`example_db/rds_setup/rds-ca-rsa4096-g1.pem`](example_db/rds_setup/rds-ca-rsa4096-g1.pem).
- An NCC bound to the workspace (the main SRA config's `ncc_id` output).
- A Databricks service principal that is an **account admin** (NCC rule) and a **workspace admin** (connection and catalog).

## Usage

```bash
cp template.tfvars.example terraform.tfvars
# edit terraform.tfvars: region, resource_prefix, vpc_id, nlb_subnet_ids, oracle_*, ncc_id, databricks_*

export DATABRICKS_CLIENT_ID=...
export DATABRICKS_CLIENT_SECRET=...
export TF_VAR_oracle_password=...

terraform init
terraform apply -var-file=terraform.tfvars
```

## TLS is mandatory under the Compliance Security Profile

CSP (FIPS) workspaces **reject Oracle Native Network Encryption**, so the connection always uses TLS:

- `encryption_protocol = "TLS"` on the connection, connecting to the TCPS listener on `oracle_port`.
- The CA chain from `server_certificate_path` is passed as `userProvidedServerCertificate`. It must match the CA that signed the server certificate (for RDS, the instance's `CACertificateIdentifier`).
- `oracle_host` must match the server certificate's subject, so use the database's DNS name (e.g. the RDS endpoint address), not its IP. The NCC rule resolves that name to the private endpoint for serverless compute.
- The connection and foreign catalog use `service_name` (not `database`) for Oracle.

> The Databricks documentation describes federation TLS as Oracle Cloud only, but TLS to Amazon RDS for Oracle has been verified working in a CSP GovCloud workspace (a serverless `SHOW SCHEMAS` against the foreign catalog returns rows).

## CDC ingestion (Lakeflow Connect)

The LogMiner-based Oracle connector's validator **rejects the RDS master user** even when it holds every required privilege, so `oracle_user` must be a **dedicated replication user** created by Databricks' `dbx_oracle_setup_util` package. The [`cdc_setup`](cdc_setup) helpers do this over TLS from serverless compute. All take the host and credentials as notebook or job parameters, and the notebooks embed the public us-gov-west-1 RDS CA (replace it for other regions).

| File | Purpose |
|------|---------|
| `setup_oracle_cdc_notebook.py` | Prerequisites: archive log retention and database supplemental logging (minimal + primary key). |
| `dbx-oracle-setup-package.sql` | Databricks' official `dbx_oracle_setup_util` package. |
| `run_dbx_setup_notebook.py` | Installs the package, then runs `create_user`, `grant_permissions`, `grant_select_permissions`, and `validate_setup` for the dedicated CDC user. |
| `oracle_cdc_setup.sql` | SQL reference for the prerequisites, for running from a SQL client with direct database access. |
| `classic_conn_diag_notebook.py` | Troubleshooting: DNS, TCP, and TLS handshake test to the database on `2484`. |
| `verify_privs_notebook.py` | Troubleshooting: verifies the ingestion user has the CDC privileges. |

`setup_oracle_cdc_notebook.py` and `oracle_cdc_setup.sql` use the Amazon RDS `rdsadmin` procedures; for self-managed Oracle, run the equivalent `ALTER DATABASE` statements as a DBA.

Flow:

1. Run `setup_oracle_cdc_notebook.py` as the master user to enable archive log retention and supplemental logging. ARCHIVELOG mode itself requires automated backups on RDS.
2. Run `run_dbx_setup_notebook.py` to create the dedicated user (for example `DBX_CDC`). `validate_setup` prints *Privilege validation passed.*
3. Optionally run [`example_db/test_data_setup/create_sample_table_notebook.py`](example_db/test_data_setup/create_sample_table_notebook.py) to create a demo schema and source table with a plain `NUMBER` primary key, readable by the CDC user.
4. Set `oracle_user` and `TF_VAR_oracle_password` to the dedicated user and apply this customization.
5. Create the Lakeflow Connect ingestion pipeline using the `connection_name` output.

Known issues:

- **No IDENTITY columns** on source tables. LogMiner skips any table with an IDENTITY column; use a plain `NUMBER` primary key.
- `python-oracledb` thin mode with RDS Oracle TLS: OpenSSL 3 rejects the RDS ciphers at the default security level. The notebooks set `ctx.set_ciphers("DEFAULT:@SECLEVEL=1")`, `minimum_version = TLSv1_2`, and pass the RDS CA via `ssl_context`.

## Integrating into the main SRA config (`aws/tf`)

To manage this alongside the rest of your deployment instead of as a separate root, fold it into `aws/tf` as a module:

1. Create a new directory `modules/oracle` and copy `main.tf`, `variables.tf`, and `outputs.tf` into it. Do **not** copy `versions.tf` as-is, because a child module must not declare `provider` blocks. Instead, create a `versions.tf` containing only the provider requirements, and declare the two Databricks aliases:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
    databricks = {
      source                = "databricks/databricks"
      version               = ">= 1.121, < 2.0"
      configuration_aliases = [databricks.account, databricks.workspace]
    }
  }
}
```
2. Remove `databricks_account_id`, `databricks_workspace_host`, and the `databricks_account_host` local from the module copy, since the root providers handle them.
3. Add a module block to the root, passing the existing providers and NCC:
```hcl
module "oracle" {
  source = "./modules/oracle"
  providers = {
    aws                  = aws
    databricks.account   = databricks.mws
    databricks.workspace = databricks.created_workspace
  }

  region               = var.region
  resource_prefix      = var.resource_prefix
  databricks_gov_shard = var.databricks_gov_shard
  ncc_id               = module.network_connectivity_configuration.ncc_id

  vpc_id                  = module.vpc[0].vpc_id        # or var.custom_vpc_id
  nlb_subnet_ids          = module.vpc[0].intra_subnets # place the NLB in the PrivateLink subnets
  oracle_host             = "mydb.xxxxxxxxxxxx.us-gov-west-1.rds.amazonaws.com"
  oracle_ip_address       = "10.0.1.20"
  oracle_service_name     = "ORCL"
  oracle_user             = "DBX_CDC"
  oracle_password         = var.oracle_password
  server_certificate_path = "${path.root}/rds-ca-rsa4096-g1.pem"
}
```

## Notes

- **RDS private IPs are not stable.** RDS resolves its endpoint DNS name to a private IP that can change on failover, scaling, or maintenance. This customization targets a fixed IP (`oracle_ip_address`) for simplicity; if the IP moves, re-resolve and re-apply.
- **Acceptance.** `acceptance_required` defaults to `false` here (unlike the other PrivateLink customizations), because the Unity Catalog connection validates connectivity when it is created. Only the allowlisted Databricks role can connect. If you set it to `true`, the NCC rule stays **PENDING** and the connection fails to create until you accept the endpoint connection; accept it, then re-apply.
- **Secrets in state.** `oracle_password` is stored in the Unity Catalog connection and in Terraform state. Supply it via `TF_VAR_oracle_password` and protect the state backend accordingly.
- Use at least two AZs in `nlb_subnet_ids`; for cross-region serverless the endpoint service must span at least two AZs.
