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

`databricks_gov_shard` defaults to `null` and is ignored for commercial regions, but is **required** when `region = us-gov-west-1` — Terraform errors out at plan time if it is unset there, so a GovCloud deployment can't silently allowlist the wrong role. Set `allowed_principals = ["*"]` to use the simplified allow-all approach from the docs instead.

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

If you want this managed alongside the rest of your deployment instead of as a separate root, fold it into `aws/tf` as a module. This keeps a single `terraform apply` and lets the endpoint service flow straight into the NCC. Because the main config is region- and shard-aware, the module inherits `region` and `databricks_gov_shard` from the existing root variables — no duplicate environment toggle.

1. Create a new directory `modules/serverless_privatelink_to_kafka`
2. Copy `main.tf`, `variables.tf`, and `outputs.tf` from `customizations/serverless_privatelink/kafka` into the new directory. Do **not** copy `versions.tf` as-is — it declares a `provider "aws"` block, and a child module that receives its provider from the root (and uses `count`) must not contain one. Instead, create a `versions.tf` in the module directory containing only the provider requirement, so Terraform can resolve the `aws` provider you pass in (this silences the "Reference to undefined provider" warning):
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.76, <7.0"
    }
  }
}
```
3. Add the following variables to `aws/tf/variables.tf`:
```hcl
variable "enable_kafka_privatelink" {
  description = "Create the internal NLB and VPC endpoint service fronting an internal Kafka cluster for serverless PrivateLink."
  type        = bool
  default     = false
}

variable "kafka_brokers" {
  description = "Kafka brokers to expose through the NLB. Each broker is advertised on its own dedicated nlb_port."
  type = list(object({
    name       = string
    ip_address = string
    port       = optional(number, 9094)
    nlb_port   = number
  }))
  default = []
}
```
4. Create a new file `kafka_privatelink.tf`
5. Add the following code block into `kafka_privatelink.tf`:
```hcl
module "serverless_privatelink_to_kafka" {
  count  = var.enable_kafka_privatelink ? 1 : 0
  source = "./modules/serverless_privatelink_to_kafka"
  providers = {
    aws = aws
  }

  region               = var.region
  resource_prefix      = var.resource_prefix
  databricks_gov_shard = var.databricks_gov_shard

  vpc_id         = module.vpc[0].vpc_id        # or var.custom_vpc_id
  nlb_subnet_ids = module.vpc[0].intra_subnets # place the NLB in the PrivateLink subnets
  brokers        = var.kafka_brokers
}
```
6. Wire the endpoint service into the NCC so the private endpoint rule is created in the same apply. In `main.tf`, replace the `private_endpoint_rules` argument on the `network_connectivity_configuration` module (line 24) with:
```hcl
  private_endpoint_rules = concat(
    var.serverless_private_endpoint_rules,
    var.enable_kafka_privatelink ? [{
      key              = "kafka" # static for_each key: endpoint_service is computed and unknown at plan time
      endpoint_service = module.serverless_privatelink_to_kafka[0].vpc_endpoint_service_name
      domain_names     = ["kafka.example.internal"] # private DNS clients use to reach the brokers
    }] : [],
  )
```
7. Set `enable_kafka_privatelink = true` and `kafka_brokers = [...]` in your root `terraform.tfvars`, then `terraform apply`.

> **Accepting the connection:** the NCC rule stays **PENDING** until you accept the connection request on the VPC endpoint service (step 5), because `acceptance_required = true`. Terraform creates both sides, but acceptance is a manual/out-of-band step (or a follow-up `aws_vpc_endpoint_connection_accepter`). The endpoint service must exist before the NCC rule references its name; with the `concat(...)` above, Terraform infers that dependency automatically.

If you'd rather keep the two loosely coupled, skip steps 1–6 and just use the [standalone flow](#wiring-into-databricks-steps-3) — apply this customization on its own, then paste its `vpc_endpoint_service_name` into the root `serverless_private_endpoint_rules` tfvars value by hand.

## Kafka `advertised.listeners`

Each broker must advertise itself on the private DNS name of the Databricks-side endpoint **and its assigned `nlb_port`**, so that after bootstrap, clients reconnect to the right broker through the NLB. Keep the `nlb_port` values here in sync with each broker's `advertised.listeners` configuration.

## Notes

- The broker security groups must allow inbound traffic on each broker's configured port from the NLB subnet CIDRs (an internal NLB sources traffic from its nodes' private IPs in `nlb_subnet_ids`). Without this the target groups report unhealthy and the connection silently fails.
- Use at least two AZs in `nlb_subnet_ids`; for cross-region serverless the endpoint service must span at least two AZs.
- The `time` provider workarounds and gov-shard account/partition logic in the main SRA config are intentionally not duplicated here — this customization only creates AWS resources and needs no Databricks provider.
