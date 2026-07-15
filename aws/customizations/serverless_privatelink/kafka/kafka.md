# Serverless PrivateLink to an internal Kafka cluster (Steps 1–2)

Terraform **customization** for **steps 1 and 2** of [Configure private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network). Works across environments — the allowlisted role is selected automatically from `region` (commercial vs GovCloud) and, for GovCloud, `databricks_gov_shard` (civilian vs DoD).

This customization is self-contained and does **not** touch the main SRA workspace deployment under [`aws/tf`](../../../tf). It provisions the *customer-side* AWS infrastructure that exposes an internal Apache Kafka cluster to Databricks serverless compute over AWS PrivateLink:

- **Step 1 — Network Load Balancer.** An internal-scheme NLB in your VPC that fronts the Kafka brokers. Each broker is advertised on its **own dedicated NLB listener port** (`nlb_port`), forwarded to that broker's real IP and port via an `ip` target group. This per-broker port mapping is what lets Kafka clients address individual brokers after the bootstrap connection.
- **Step 2 — VPC endpoint service.** A VPC endpoint service (powered by AWS PrivateLink) over the NLB, with `acceptance_required = true` and the **Databricks serverless private-connectivity role** allowlisted as an allowed principal.

Steps 3–7 from the doc (create the NCC object, create the interface endpoint, accept it, confirm status, attach to workspaces) are handled on the Databricks side — see below.

## Databricks serverless private-connectivity role

The allowlisted principal is selected automatically from `region` and `databricks_gov_shard`:

| Environment | Condition | Role ARN |
|-------------|-----------|----------|
| AWS commercial | any non-GovCloud region | `arn:aws:iam::565502421330:role/private-connectivity-role-<region>` |
| AWS GovCloud (Civilian) | `region = us-gov-west-1`, `databricks_gov_shard = civilian` | `arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1` |
| AWS GovCloud (DoD) | `region = us-gov-west-1`, `databricks_gov_shard = dod` | `arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1` |

`databricks_gov_shard` is required only for `us-gov-west-1`; leave it null for commercial regions. Set `allowed_principals = ["*"]` to use the simplified allow-all approach from the docs instead.

## Usage

```bash
cp template.tfvars.example terraform.tfvars
# edit terraform.tfvars: resource_prefix, vpc_id, nlb_subnet_ids, brokers

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
       domain_names     = ["kafka.example.internal"]
     },
   ]
   ```
   That creates the NCC private endpoint rule (step 3–4). The rule stays **PENDING** until accepted.
3. Because `acceptance_required = true`, accept the connection request on this VPC endpoint service (step 5). It then transitions to established/available (steps 6–7).

## Integrating into the main SRA config (`aws/tf`)

If you want this managed alongside the rest of your deployment instead of as a separate root, fold it into `aws/tf` as a module. This keeps a single `terraform apply` and lets the endpoint service flow straight into the NCC.

**1. Add it as a module.** Copy the resource files into a module directory — everything **except** `versions.tf` (the AWS provider and `terraform {}` block already exist in `aws/tf`; a module must not redeclare them):

```bash
mkdir -p aws/tf/modules/serverless_privatelink_to_kafka
cp aws/customizations/serverless_privatelink/kafka/{main.tf,variables.tf,outputs.tf} \
   aws/tf/modules/serverless_privatelink_to_kafka/
```

**2. Call the module from `aws/tf`** (e.g. in a new `aws/tf/kafka_privatelink.tf`), reusing the root variables so it inherits the deployment's environment automatically. Because the main config is region- and shard-aware, `region` and `databricks_gov_shard` come straight from the existing root vars — no duplicate env toggle:

```hcl
# Opt-in: create the internal NLB + VPC endpoint service fronting an internal Kafka cluster
module "serverless_privatelink_to_kafka" {
  count  = var.enable_kafka_privatelink ? 1 : 0
  source = "./modules/serverless_privatelink_to_kafka"
  providers = {
    aws = aws
  }

  region               = var.region
  resource_prefix      = var.resource_prefix
  databricks_gov_shard = var.databricks_gov_shard

  vpc_id         = module.vpc[0].vpc_id       # or your custom_vpc_id
  nlb_subnet_ids = module.vpc[0].intra_subnets # place the NLB in the PrivateLink subnets
  brokers        = var.kafka_brokers
}
```

Add matching root variables to `aws/tf/variables.tf` (`enable_kafka_privatelink`, `kafka_brokers`) and values to your root tfvars. `resource_prefix` in the main config can be long, so mind the 32-char target-group name budget noted below.

**3. Wire the endpoint service into the NCC automatically.** The NCC module already consumes `var.serverless_private_endpoint_rules` (see [`aws/tf/main.tf`](../../../tf/main.tf)). Append this module's endpoint service to that list so the private endpoint rule is created in the same apply — change the `private_endpoint_rules` argument on the `network_connectivity_configuration` module in `aws/tf/main.tf`:

```hcl
module "network_connectivity_configuration" {
  # ...
  private_endpoint_rules = concat(
    var.serverless_private_endpoint_rules,
    var.enable_kafka_privatelink ? [{
      endpoint_service = module.serverless_privatelink_to_kafka[0].vpc_endpoint_service_name
      domain_names     = ["kafka.example.internal"] # private DNS clients use to reach the brokers
    }] : [],
  )
}
```

**4. Accept the connection.** The NCC rule stays **PENDING** until you accept the connection request on the VPC endpoint service (step 5), because `acceptance_required = true`. Terraform creates both sides, but acceptance is a manual/out-of-band step (or a follow-up `aws_vpc_endpoint_connection_accepter`).

> **Ordering note:** the endpoint service (this module) must exist before the NCC rule references its name. With the `concat(...)` above, Terraform infers that dependency automatically from `module.serverless_privatelink_to_kafka[0].vpc_endpoint_service_name`.

If you'd rather keep the two loosely coupled, skip steps 2–3 and just use the [standalone flow](#wiring-into-databricks-steps-3) — apply this customization on its own, then paste its `vpc_endpoint_service_name` into the root `serverless_private_endpoint_rules` tfvars value by hand.

## Kafka `advertised.listeners`

Each broker must advertise itself on the private DNS name of the Databricks-side endpoint **and its assigned `nlb_port`**, so that after bootstrap, clients reconnect to the right broker through the NLB. Keep the `nlb_port` values here in sync with each broker's `advertised.listeners` configuration.

## Notes

- Use at least two AZs in `nlb_subnet_ids`; for cross-region serverless the endpoint service must span at least two AZs.
- The `time` provider workarounds and gov-shard account/partition logic in the main SRA config are intentionally not duplicated here — this customization only creates AWS resources and needs no Databricks provider.
