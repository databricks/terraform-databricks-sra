# Serverless PrivateLink to a self-hosted Git server (Steps 1–2)

Terraform **customization** for the customer-side AWS setup in [Set up private connectivity to a Git server for serverless compute](https://docs.databricks.com/aws/en/repos/serverless-private-git), which follows **steps 1 and 2** of [Configure private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network). Works across environments — the allowlisted role is selected automatically from `region` (commercial vs GovCloud) and, for GovCloud, `databricks_gov_shard` (civilian vs DoD).

This customization is self-contained and does **not** touch the main SRA workspace deployment under [`aws/tf`](../../../tf). It provisions the *customer-side* AWS infrastructure that exposes a self-hosted Git server (GitHub Enterprise Server, GitLab self-managed, Bitbucket Data Center, etc.) to Databricks serverless compute over AWS PrivateLink:

- **Step 1 — Network Load Balancer.** An internal-scheme NLB in your VPC that fronts the Git server over TCP. Each configured port in `git_ports` (e.g. 443 for HTTPS, 22 for SSH) gets its own `ip` target group and listener, forwarding to the Git server's private IP on the same port.
- **Step 2 — VPC endpoint service.** A VPC endpoint service (powered by AWS PrivateLink) over the NLB, with `acceptance_required = true` and the **Databricks serverless private-connectivity role** allowlisted as an allowed principal.

The remaining steps (create the NCC object and private endpoint rule, accept the connection, then enable the Serverless Private Git preview) are handled on the Databricks side — see below.

> **One region per endpoint service.** A VPC endpoint service can only serve workspaces in its own region. Deploy this customization once per region that needs private Git access.

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
# edit terraform.tfvars: resource_prefix, vpc_id, nlb_subnet_ids, git_ip_address, git_ports

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
       domain_names     = ["git.example.internal"]
     },
   ]
   ```
   That creates the NCC private endpoint rule. The rule stays **PENDING** until accepted.
3. Because `acceptance_required = true`, accept the connection request on this VPC endpoint service. It then transitions to established/available.
4. Wait at least **10 minutes** after the NCC private endpoint rule is established, then enable the **Serverless Private Git** preview in your workspace settings ([docs](https://docs.databricks.com/aws/en/repos/serverless-private-git)).
5. If [serverless egress control](https://docs.databricks.com/aws/en/security/network/serverless-network-security/serverless-firewall) is enabled, add the Git server's FQDN to the allowed internet destinations.
6. Optional: create `/Workspace/.git_settings/config.json` to customize SSL verification, CA certificates, HTTP proxies, or custom ports per remote (see the docs).

## Integrating into the main SRA config (`aws/tf`)

If you want this managed alongside the rest of your deployment instead of as a separate root, fold it into `aws/tf` as a module. This keeps a single `terraform apply` and lets the endpoint service flow straight into the NCC. Because the main config is region- and shard-aware, the module inherits `region` and `databricks_gov_shard` from the existing root variables — no duplicate environment toggle.

1. Create a new directory `modules/serverless_privatelink_to_git`
2. Copy `main.tf`, `variables.tf`, and `outputs.tf` from `customizations/serverless_privatelink/git` into the new directory. Do **not** copy `versions.tf` as-is — it declares a `provider "aws"` block, and a child module that receives its provider from the root (and uses `count`) must not contain one. Instead, create a `versions.tf` in the module directory containing only the provider requirement, so Terraform can resolve the `aws` provider you pass in (this silences the "Reference to undefined provider" warning):
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
variable "enable_git_privatelink" {
  description = "Create the internal NLB and VPC endpoint service fronting a self-hosted Git server for serverless PrivateLink."
  type        = bool
  default     = false
}

variable "git_ip_address" {
  description = "Private IP of the Git server the NLB forwards to."
  type        = string
  default     = null
}

variable "git_ports" {
  description = "Ports the Git server serves on (e.g. 443 HTTPS, 22 SSH). Each is fronted by its own NLB listener and target group."
  type        = list(number)
  default     = [443]
}
```
4. Create a new file `git_privatelink.tf`
5. Add the following code block into `git_privatelink.tf`:
```hcl
module "serverless_privatelink_to_git" {
  count  = var.enable_git_privatelink ? 1 : 0
  source = "./modules/serverless_privatelink_to_git"
  providers = {
    aws = aws
  }

  region               = var.region
  resource_prefix      = var.resource_prefix
  databricks_gov_shard = var.databricks_gov_shard

  vpc_id         = module.vpc[0].vpc_id        # or var.custom_vpc_id
  nlb_subnet_ids = module.vpc[0].intra_subnets # place the NLB in the PrivateLink subnets
  git_ip_address = var.git_ip_address
  git_ports      = var.git_ports
}
```
6. Wire the endpoint service into the NCC so the private endpoint rule is created in the same apply. In `main.tf`, replace the `private_endpoint_rules` argument on the `network_connectivity_configuration` module (line 24) with:
```hcl
  private_endpoint_rules = concat(
    var.serverless_private_endpoint_rules,
    var.enable_git_privatelink ? [{
      key              = "git" # static for_each key: endpoint_service is computed and unknown at plan time
      endpoint_service = module.serverless_privatelink_to_git[0].vpc_endpoint_service_name
      domain_names     = ["git.example.internal"] # private DNS clients use to reach the Git server
    }] : [],
  )
```
7. Set `enable_git_privatelink = true`, `git_ip_address`, and `git_ports` in your root `terraform.tfvars`, then `terraform apply`.

> **Accepting the connection:** the NCC rule stays **PENDING** until you accept the connection request on the VPC endpoint service, because `acceptance_required = true`. Terraform creates both sides, but acceptance is a manual/out-of-band step (or a follow-up `aws_vpc_endpoint_connection_accepter`). The endpoint service must exist before the NCC rule references its name; with the `concat(...)` above, Terraform infers that dependency automatically.

> **After the rule is established**, wait ~10 minutes, then enable the Serverless Private Git preview in your workspace settings (see step 4 above). This is a Databricks-side step Terraform does not perform.

If you'd rather keep the two loosely coupled, skip steps 1–6 and just use the [standalone flow](#wiring-into-databricks-steps-3) — apply this customization on its own, then paste its `vpc_endpoint_service_name` into the root `serverless_private_endpoint_rules` tfvars value by hand.

## Notes

- The Git server's security group must allow inbound traffic on each port in `git_ports` from the NLB subnet CIDRs (an internal NLB sources traffic from its nodes' private IPs in `nlb_subnet_ids`). Without this the target groups report unhealthy and the connection silently fails.
- If the Git server's private IP can change, front it with a stable Route 53 record and set `git_ip_address` to that record's address so the target registration stays valid.
- Use at least two AZs in `nlb_subnet_ids`; for cross-region serverless the endpoint service must span at least two AZs.
- The `time` provider workarounds and gov-shard account/partition logic in the main SRA config are intentionally not duplicated here — this customization only creates AWS resources and needs no Databricks provider.
