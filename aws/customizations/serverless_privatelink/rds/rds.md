# Serverless PrivateLink to an internal RDS instance (Steps 1–2)

Terraform **customization** for **steps 1 and 2** of [Configure private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network). Works across environments — the allowlisted role is selected automatically from `region` (commercial vs GovCloud) and, for GovCloud, `databricks_gov_shard` (civilian vs DoD).

This customization is self-contained and does **not** touch the main SRA workspace deployment under [`aws/tf`](../../../tf). It provisions the *customer-side* AWS infrastructure that exposes an internal Amazon RDS instance (PostgreSQL, MySQL, Aurora, SQL Server, Oracle) to Databricks serverless compute over AWS PrivateLink:

- **Step 1 — Network Load Balancer.** An internal-scheme NLB in your VPC that fronts the RDS endpoint over TCP. A single `ip` target group forwards to the database's private IP and port, and one listener advertises the database to serverless compute on `nlb_port` (defaults to the native `db_port`).
- **Step 2 — VPC endpoint service.** A VPC endpoint service (powered by AWS PrivateLink) over the NLB, with `acceptance_required = true` and the **Databricks serverless private-connectivity role** allowlisted as an allowed principal.

Steps 3–7 from the doc (create the NCC object, create the interface endpoint, accept it, confirm status, attach to workspaces) are handled on the Databricks side — see below.

## Databricks serverless private-connectivity role

The allowlisted principal is selected automatically from `region` and `databricks_gov_shard`:

| Environment | Condition | Role ARN |
|-------------|-----------|----------|
| AWS commercial | any non-GovCloud region | `arn:aws:iam::565502421330:role/private-connectivity-role-<region>` |
| AWS GovCloud (Civilian) | `region = us-gov-west-1`, `databricks_gov_shard = civilian` | `arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1` |
| AWS GovCloud (DoD) | `region = us-gov-west-1`, `databricks_gov_shard = dod` | `arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1` |

`databricks_gov_shard` defaults to `null` and is ignored for commercial regions, but is **required** when `region = us-gov-west-1` — Terraform errors out at plan time if it is unset there, so a GovCloud deployment can't silently allowlist the wrong role. Set `allowed_principals = ["*"]` to use the simplified allow-all approach from the docs instead.

## Usage

```bash
cp template.tfvars.example terraform.tfvars
# edit terraform.tfvars: resource_prefix, vpc_id, nlb_subnet_ids, db_ip_address, db_port

terraform init
terraform apply -var-file=terraform.tfvars
```

## Wiring into Databricks (steps 3+)

1. Take the `vpc_endpoint_service_name` output (`com.amazonaws.vpce.<region>.vpce-svc-…`).
2. Add it to the SRA root `serverless_private_endpoint_rules` variable (see [`aws/tf/template.tfvars.example`](../../../tf/template.tfvars.example)), e.g.:
   ```hcl
   serverless_private_endpoint_rules = [
     {
       endpoint_service = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-xxxxxxxxxxxxxxxxx"
       domain_names     = ["mydb.example.internal"]
     },
   ]
   ```
   That creates the NCC private endpoint rule (step 3–4). The rule stays **PENDING** until accepted.
3. Because `acceptance_required = true`, accept the connection request on this VPC endpoint service (step 5). It then transitions to established/available (steps 6–7).

## Integrating into the main SRA config (`aws/tf`)

If you want this managed alongside the rest of your deployment instead of as a separate root, fold it into `aws/tf` as a module. This keeps a single `terraform apply` and lets the endpoint service flow straight into the NCC. Because the main config is region- and shard-aware, the module inherits `region` and `databricks_gov_shard` from the existing root variables — no duplicate environment toggle.

1. Create a new directory `modules/serverless_privatelink_to_rds`
2. Copy `main.tf`, `variables.tf`, and `outputs.tf` from `customizations/serverless_privatelink/rds` into the new directory. Do **not** copy `versions.tf` — the AWS provider and `terraform {}` block already exist in `aws/tf` and a module must not redeclare them.
3. Add the following variables to `variables.tf`:
```hcl
variable "enable_rds_privatelink" {
  description = "Create the internal NLB and VPC endpoint service fronting an internal RDS instance for serverless PrivateLink."
  type        = bool
  default     = false
}

variable "rds_ip_address" {
  description = "Private IP of the RDS endpoint the NLB forwards to."
  type        = string
  default     = null
}

variable "rds_port" {
  description = "Port the RDS engine listens on (e.g. 5432 PostgreSQL, 3306 MySQL, 1433 SQL Server, 1521 Oracle)."
  type        = number
  default     = 5432
}
```
4. Create a new file `rds_privatelink.tf`
5. Add the following code block into `rds_privatelink.tf`:
```hcl
module "serverless_privatelink_to_rds" {
  count  = var.enable_rds_privatelink ? 1 : 0
  source = "./modules/serverless_privatelink_to_rds"
  providers = {
    aws = aws
  }

  region               = var.region
  resource_prefix      = var.resource_prefix
  databricks_gov_shard = var.databricks_gov_shard

  vpc_id         = module.vpc[0].vpc_id        # or var.custom_vpc_id
  nlb_subnet_ids = module.vpc[0].intra_subnets # place the NLB in the PrivateLink subnets
  db_ip_address  = var.rds_ip_address
  db_port        = var.rds_port
}
```
6. Wire the endpoint service into the NCC so the private endpoint rule is created in the same apply. In `main.tf`, replace the `private_endpoint_rules` argument on the `network_connectivity_configuration` module (line 24) with:
```hcl
  private_endpoint_rules = concat(
    var.serverless_private_endpoint_rules,
    var.enable_rds_privatelink ? [{
      endpoint_service = module.serverless_privatelink_to_rds[0].vpc_endpoint_service_name
      domain_names     = ["mydb.example.internal"] # private DNS clients use to reach the database
    }] : [],
  )
```
7. Set `enable_rds_privatelink = true`, `rds_ip_address`, and `rds_port` in your root `terraform.tfvars`, then `terraform apply`.

> **Accepting the connection:** the NCC rule stays **PENDING** until you accept the connection request on the VPC endpoint service (step 5), because `acceptance_required = true`. Terraform creates both sides, but acceptance is a manual/out-of-band step (or a follow-up `aws_vpc_endpoint_connection_accepter`). The endpoint service must exist before the NCC rule references its name; with the `concat(...)` above, Terraform infers that dependency automatically.

If you'd rather keep the two loosely coupled, skip steps 1–6 and just use the [standalone flow](#wiring-into-databricks-steps-3) — apply this customization on its own, then paste its `vpc_endpoint_service_name` into the root `serverless_private_endpoint_rules` tfvars value by hand.

## Notes

- **RDS private IPs are not stable.** RDS resolves its endpoint DNS name to a private IP that can change on failover, scaling, or maintenance. This customization targets a fixed IP (`db_ip_address`) for simplicity; if the IP moves, re-resolve and re-apply, or front the database with a stable Route 53 record and target that. For Aurora, point at the cluster (writer) endpoint's current IP.
- The RDS instance's security group must allow inbound traffic on the database's port (`db_port`) from the NLB subnet CIDRs (an internal NLB sources traffic from its nodes' private IPs in `nlb_subnet_ids`). Without this the target group reports unhealthy and the connection silently fails.
- Use at least two AZs in `nlb_subnet_ids`; for cross-region serverless the endpoint service must span at least two AZs.
- The `time` provider workarounds and gov-shard account/partition logic in the main SRA config are intentionally not duplicated here — this customization only creates AWS resources and needs no Databricks provider.
