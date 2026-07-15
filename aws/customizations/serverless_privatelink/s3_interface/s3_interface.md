# Serverless PrivateLink to S3 via an interface endpoint (Steps 1–2)

Terraform **customization** for **steps 1 and 2** of [Configure private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network). Works across environments — the allowlisted role is selected automatically from `region` (commercial vs GovCloud) and, for GovCloud, `databricks_gov_shard` (civilian vs DoD).

This customization is self-contained and does **not** touch the main SRA workspace deployment under [`aws/tf`](../../../tf). It provisions the *customer-side* AWS infrastructure that exposes Amazon S3 to Databricks serverless compute through your own VPC endpoint service over AWS PrivateLink:

- **Step 1 — S3 interface endpoint + Network Load Balancer.** An S3 *interface* VPC endpoint in your VPC (private DNS disabled, since the NLB fronts it), plus an internal-scheme NLB whose `ip` target group forwards TCP 443 to the interface endpoint's ENI private IPs. One listener advertises S3 to serverless compute on 443.
- **Step 2 — VPC endpoint service.** A VPC endpoint service (powered by AWS PrivateLink) over the NLB, with `acceptance_required = true` and the **Databricks serverless private-connectivity role** allowlisted as an allowed principal.

Steps 3–7 from the doc (create the NCC object, create the interface endpoint, accept it, confirm status, attach to workspaces) are handled on the Databricks side — see below.

## When to use this vs. the native S3 path

> [!IMPORTANT]
> For most S3 access, you do **not** need this. Databricks supports a simpler native path — an NCC private endpoint rule targeting **S3 bucket names** (`resource_names`) instead of a VPC endpoint service. That avoids running your own NLB and interface endpoint entirely. See the `serverless_private_endpoint_rules` variable in [`aws/tf/template.tfvars.example`](../../../tf/template.tfvars.example):
>
> ```hcl
> serverless_private_endpoint_rules = [
>   { resource_names = ["my-bucket"] },
> ]
> ```
>
> Use **this** customization only when you specifically need S3 reachable through your own VPC endpoint service / NLB — for example, to funnel S3 through the same private path as your other internal services, or to apply your own endpoint policy or traffic inspection.

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
# edit terraform.tfvars: resource_prefix, vpc_id, nlb_subnet_ids,
#   s3_endpoint_subnet_ids, s3_endpoint_security_group_ids

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
       domain_names     = ["s3.example.internal"]
     },
   ]
   ```
   That creates the NCC private endpoint rule (step 3–4). The rule stays **PENDING** until accepted.
3. Because `acceptance_required = true`, accept the connection request on this VPC endpoint service (step 5). It then transitions to established/available (steps 6–7).

## Integrating into the main SRA config (`aws/tf`)

If you want this managed alongside the rest of your deployment instead of as a separate root, fold it into `aws/tf` as a module. This keeps a single `terraform apply` and lets the endpoint service flow straight into the NCC. Because the main config is region- and shard-aware, the module inherits `region` and `databricks_gov_shard` from the existing root variables — no duplicate environment toggle.

1. Create a new directory `modules/serverless_privatelink_to_s3`
2. Copy `main.tf`, `variables.tf`, and `outputs.tf` from `customizations/serverless_privatelink/s3_interface` into the new directory. Do **not** copy `versions.tf` — the AWS provider and `terraform {}` block already exist in `aws/tf` and a module must not redeclare them.
3. Add the following variable to `variables.tf`:
```hcl
variable "enable_s3_privatelink" {
  description = "Create the S3 interface endpoint, internal NLB, and VPC endpoint service for serverless PrivateLink to S3."
  type        = bool
  default     = false
}
```
4. Create a new file `s3_privatelink.tf`
5. Add the following code block into `s3_privatelink.tf`:
```hcl
module "serverless_privatelink_to_s3" {
  count  = var.enable_s3_privatelink ? 1 : 0
  source = "./modules/serverless_privatelink_to_s3"
  providers = {
    aws = aws
  }

  region               = var.region
  resource_prefix      = var.resource_prefix
  databricks_gov_shard = var.databricks_gov_shard

  vpc_id                         = module.vpc[0].vpc_id        # or var.custom_vpc_id
  nlb_subnet_ids                 = module.vpc[0].intra_subnets # place the NLB in the PrivateLink subnets
  s3_endpoint_subnet_ids         = module.vpc[0].intra_subnets # S3 endpoint ENIs in the same AZs
  s3_endpoint_security_group_ids = [aws_security_group.privatelink[0].id]
}
```
6. Wire the endpoint service into the NCC so the private endpoint rule is created in the same apply. In `main.tf`, replace the `private_endpoint_rules` argument on the `network_connectivity_configuration` module (line 24) with:
```hcl
  private_endpoint_rules = concat(
    var.serverless_private_endpoint_rules,
    var.enable_s3_privatelink ? [{
      endpoint_service = module.serverless_privatelink_to_s3[0].vpc_endpoint_service_name
      domain_names     = ["s3.example.internal"] # private DNS clients use to reach S3
    }] : [],
  )
```
7. Set `enable_s3_privatelink = true` in your root `terraform.tfvars`, then `terraform apply`.

> **Accepting the connection:** the NCC rule stays **PENDING** until you accept the connection request on the VPC endpoint service (step 5), because `acceptance_required = true`. Terraform creates both sides, but acceptance is a manual/out-of-band step (or a follow-up `aws_vpc_endpoint_connection_accepter`). The endpoint service must exist before the NCC rule references its name; with the `concat(...)` above, Terraform infers that dependency automatically.

If you'd rather keep the two loosely coupled, skip steps 1–6 and just use the [standalone flow](#wiring-into-databricks-steps-3) — apply this customization on its own, then paste its `vpc_endpoint_service_name` into the root `serverless_private_endpoint_rules` tfvars value by hand.

## Notes

- **Private DNS is disabled** on the S3 interface endpoint because the NLB fronts it; consumers reach S3 through the endpoint service's private DNS name, not the AWS-managed one. Serverless clients must address S3 via the `domain_names` you configure on the NCC rule.
- Keep `nlb_subnet_ids` and `s3_endpoint_subnet_ids` in the **same AZs**, and ensure `s3_endpoint_security_group_ids` allows inbound TCP 443 from the NLB subnets / VPC CIDR, or the target group will report unhealthy.
- Use at least two AZs; for cross-region serverless the endpoint service must span at least two AZs.
- The `time` provider workarounds and gov-shard account/partition logic in the main SRA config are intentionally not duplicated here — this customization only creates AWS resources and needs no Databricks provider.
