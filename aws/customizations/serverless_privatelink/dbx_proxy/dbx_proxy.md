# Serverless PrivateLink via dbx-proxy (multi-backend / L7)

Terraform **customization** for **steps 1 and 2** of [Configure private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network), using the [databricks-solutions/dbx-proxy](https://github.com/databricks-solutions/dbx-proxy) module (pinned to commit `b95878a`, the merge of [#7](https://github.com/databricks-solutions/dbx-proxy/pull/7); switch to a version tag once one is cut).

This is the **multi-backend / Layer 7** option. The other modules in this folder (`rds`, `kafka`, `git`, `s3_interface`) each front a single TCP backend with an NLB and a VPC endpoint service. `dbx-proxy` generalizes that: an internal NLB fronts a fleet of [HAProxy](https://www.haproxy.org/) instances (an EC2 autoscaling group) that can route to **multiple** backends and can route at **Layer 7** (SNI / HTTP host) as well as Layer 4 (TCP), all behind one VPC endpoint service.

```
Databricks Serverless → interface endpoint → VPC endpoint service → NLB → dbx-proxy (HAProxy) → your backends
```

Use this when serverless compute must reach several private resources through one endpoint service, or needs host/SNI-based routing. For a single TCP backend, the purpose-built single-backend modules in this folder are simpler. Works across commercial and GovCloud (civilian/DoD), like the other modules in this folder.

You can run this **standalone** or **fold it into the main SRA config** — see the two sections below.

## How this differs from the other modules in this folder

- **It wraps an external module.** `main.tf` sources `databricks-solutions/dbx-proxy//terraform/aws` pinned to commit `b95878a`. The variables here map onto that module's inputs; see its [`terraform/aws/README.md`](https://github.com/databricks-solutions/dbx-proxy/tree/main/terraform/aws) for full detail. `terraform init` fetches it over Git, so network access to GitHub is required.
- **It runs compute.** Unlike the NLB-only modules, dbx-proxy provisions an EC2 autoscaling group running the dbx-proxy container, IAM instance profile, and (in bootstrap mode) optionally a VPC/subnets/NAT. That is a larger footprint and lifecycle to own.
- **It cannot be toggled with `count`.** The upstream module declares its own `provider "aws"` block, so any module that sources it may **not** use `count`, `for_each`, or `depends_on` (Terraform rejects these on modules with local provider configurations). This is why the fold-in below adds the module unconditionally rather than behind an `enable_*` flag. See [Making it optional](#making-it-optional).

## Databricks serverless private-connectivity role

The principal allowlisted on the VPC endpoint service is selected automatically from `region` and `databricks_gov_shard` and passed to dbx-proxy via its `allowed_principals` input:

| Environment | Condition | Role ARN |
|-------------|-----------|----------|
| AWS commercial | any non-GovCloud region | `arn:aws:iam::565502421330:role/private-connectivity-role-<region>` |
| AWS GovCloud (Civilian) | `region = us-gov-west-1`, `databricks_gov_shard = civilian` | `arn:aws-us-gov:iam::347038500609:role/private-connectivity-role-us-gov-west-1` |
| AWS GovCloud (DoD) | `region = us-gov-west-1`, `databricks_gov_shard = dod` | `arn:aws-us-gov:iam::347034940029:role/private-connectivity-role-us-gov-west-1` |

`databricks_gov_shard` defaults to `null` and is ignored for commercial regions, but is **required** when `region = us-gov-west-1` — Terraform errors at plan time if it is unset there. Set `allowed_principals = ["*"]` to use the simplified allow-all approach from the docs instead.

## Deployment modes

- **`bootstrap`** (default) — creates a new NLB and VPC endpoint service. Either creates a new VPC + subnets (from `vpc_cidr` / `subnet_cidrs`) or uses an existing one you pass via `vpc_id` + `subnet_ids`.
- **`proxy-only`** — attaches listeners/target groups to an **existing** NLB (`nlb_arn`) in an existing `vpc_id` + `subnet_ids`.

## Option 1: Standalone

Run this customization as its own Terraform root, then paste its `vpc_endpoint_service_name` output into the main SRA root's `serverless_private_endpoint_rules` value by hand. This keeps the proxy's lifecycle fully separate from the workspace deployment (two applies, two state files).

```bash
cp template.tfvars.example terraform.tfvars
# edit terraform.tfvars: region, databricks_gov_shard, resource_prefix, deployment_mode, networking, dbx_proxy_listener

terraform init   # fetches the dbx-proxy module from GitHub
terraform apply -var-file=terraform.tfvars
```

Then follow [Wiring into Databricks](#wiring-into-databricks-steps-3) below.

## Option 2: Fold into the main SRA config (`aws/tf`)

Folding this in lets a single `terraform apply` stand up the proxy **and** register its endpoint service with the Network Connectivity Configuration, so serverless compute can reach your backends after one apply plus a connection acceptance. This follows the same pattern as the RDS customization's fold-in, with two differences: the module is region/shard-aware from the root variables, and it is added **unconditionally** (no enable flag — see [Making it optional](#making-it-optional)).

### 1. Create the module directory

Create `aws/tf/modules/databricks_workspace/dbx_proxy/` and copy `main.tf`, `variables.tf`, and `outputs.tf` from this customization into it.

Do **not** copy `versions.tf` as-is — it declares a `provider "aws"` block, and a child module that receives its provider from the root must not contain one. Create a `versions.tf` in the new module directory with only the provider requirements:

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

> The sourced `dbx-proxy` module still declares its own `provider "aws"`. That is what makes the folded-in module a "legacy module" and blocks `count`/`for_each` on it — see [Making it optional](#making-it-optional).

### 2. Add the minimal root variables

Add to `aws/tf/variables.tf`. `region`, `resource_prefix`, and `databricks_gov_shard` already exist at the root and are reused — you only add the routing definition and, if bootstrapping a network for the proxy, its CIDRs:

```hcl
variable "dbx_proxy_listener" {
  description = "dbx-proxy listener/routing definition. Each listener is a frontend port with routes to one or more backends. mode = \"tcp\" (L4) or \"http\" (L7, SNI/host)."
  type = list(object({
    name = string
    mode = string
    port = number
    routes = list(object({
      name    = string
      domains = list(string)
      destinations = list(object({
        name = string
        host = string
        port = number
      }))
    }))
  }))
  default = []
}

variable "dbx_proxy_subnet_cidrs" {
  description = "Subnet CIDRs for the dbx-proxy NLB + autoscaling group when it bootstraps its own VPC. Use at least two AZs."
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}
```

Everything else the module needs has a sensible default (`deployment_mode = "bootstrap"`, `instance_type`, capacities, image version, health port, etc.). Expose more of them as root variables only if you need to tune them — see [`variables.tf`](variables.tf) in this folder for the full list.

> The default `dbx_proxy_subnet_cidrs` uses a different range (`10.1.0.0/16`) than SRA's workspace VPC so dbx-proxy can bootstrap its own isolated VPC. To place the proxy inside SRA's existing VPC instead, skip this variable and pass `deployment_mode`, `vpc_id`, and `subnet_ids` from SRA's `module.vpc` in step 3.

### 3. Add the module

Create `aws/tf/dbx_proxy.tf`:

```hcl
module "dbx_proxy" {
  source = "./modules/databricks_workspace/dbx_proxy"
  providers = {
    aws = aws
  }

  region               = var.region
  resource_prefix      = var.resource_prefix
  databricks_gov_shard = var.databricks_gov_shard

  # Bootstrap an isolated VPC for the proxy:
  deployment_mode = "bootstrap"
  subnet_cidrs    = var.dbx_proxy_subnet_cidrs

  # ...or place it in SRA's workspace VPC instead (comment out subnet_cidrs above):
  # vpc_id     = module.vpc[0].vpc_id
  # subnet_ids = module.vpc[0].intra_subnets

  dbx_proxy_listener = var.dbx_proxy_listener
}
```

### 4. Register the endpoint service with the NCC

Wire the endpoint service into the NCC so the private endpoint rule is created in the same apply. In `main.tf`, replace the `private_endpoint_rules` argument on the `network_connectivity_configuration` module with:

```hcl
  private_endpoint_rules = concat(
    var.serverless_private_endpoint_rules,
    length(var.dbx_proxy_listener) > 0 ? [{
      key              = "dbx-proxy" # static for_each key: endpoint_service is computed and unknown at plan time
      endpoint_service = module.dbx_proxy.vpc_endpoint_service_name
      domain_names     = ["app.internal.example.com"] # private DNS name(s) clients use to reach the backends
    }] : [],
  )
```

The endpoint service must exist before the NCC rule references its name; with the `concat(...)` above, Terraform infers that dependency automatically.

### 5. Apply

Set `dbx_proxy_listener` (and, if bootstrapping, `dbx_proxy_subnet_cidrs`) in your root `terraform.tfvars`, then `terraform apply`.

> **Accepting the connection:** the NCC rule stays **PENDING** until you accept the connection request on the VPC endpoint service (dbx-proxy sets `acceptance_required = true`). Terraform creates both sides, but acceptance is a manual/out-of-band step (or a follow-up `aws_vpc_endpoint_connection_accepter`).

### Making it optional

The other single-backend modules in this folder are gated with `count = var.enable_* ? 1 : 0`. That is **not possible** for dbx-proxy: the upstream module declares its own `provider "aws"` configuration, and Terraform forbids `count`, `for_each`, and `depends_on` on any module that sources a module with local provider configurations. So the fold-in above always creates the proxy. To make it optional, either:

- **Keep it standalone** ([Option 1](#option-1-standalone)) so its lifecycle stays separate, or
- **Have the upstream module accept a passed-in provider.** If `databricks-solutions/dbx-proxy` removes its internal `provider "aws"` block and expects the provider from its caller, the folded-in module could then be wrapped with `count` behind an `enable_dbx_proxy` flag like the others. This requires an upstream change.

## Wiring into Databricks (steps 3+)

1. Take the `vpc_endpoint_service_name` output (`com.amazonaws.vpce.<region>.vpce-svc-…`).
2. Add it to the SRA root `serverless_private_endpoint_rules` variable (see [`aws/tf/template.tfvars.example`](../../../tf/template.tfvars.example)), e.g.:
   ```hcl
   serverless_private_endpoint_rules = [
     {
       endpoint_service = "com.amazonaws.vpce.us-east-1.vpce-svc-xxxxxxxxxxxxxxxxx"
       domain_names     = ["app-a.internal.example.com", "db.internal.example.com"]
     },
   ]
   ```
   That creates the NCC private endpoint rule (steps 3–4). The rule stays **PENDING** until accepted.
3. dbx-proxy creates the endpoint service with `acceptance_required = true`, so accept the connection request on the VPC endpoint service (step 5). It then transitions to established/available (steps 6–7).

> If you folded the module into `aws/tf` (Option 2, step 4), the NCC rule is created for you by the `concat(...)` wiring — you only need to accept the connection request.

## Notes

- **Instances are replaced every 25 days.** This wrapper hardcodes `max_instance_lifetime = 2160000` (25 days) so the Auto Scaling group rotates every proxy instance onto the latest patched AMI on a fixed cadence, satisfying compliance patching mandates (e.g. FedRAMP). This is intentionally not a variable — it applies to all SRA users of this proxy — and carries over when you fold the module into `aws/tf`.
  - **Expect a brief outage on each rotation with the default single instance.** The defaults are `min_capacity = 1` and `max_capacity = 1`, so the Auto Scaling group cannot launch a replacement before terminating the old instance — each 25-day rotation causes a short connection interruption while the instance recycles (this happens on the timer, with no `terraform apply`).
  - **To avoid the outage, run at least two instances** across multiple AZs so replacements roll one at a time. Set **both** `min_capacity = 2` and `max_capacity = 2` (both default to 1; `max_capacity` must be raised too, otherwise the group can't add a second instance):
    ```hcl
    min_capacity = 2
    max_capacity = 2
    ```
- **Container image egress.** In bootstrap mode with `enable_nat_gateway = true`, a NAT + Internet Gateway is created so instances can pull the dbx-proxy container image. If you supply your own network with no outbound path, ensure the instances can still reach the image registry.
- **`dbx_proxy_health_port` must not collide** with any `dbx_proxy_listener` port; the upstream module enforces this at plan time.
- **Backends must be reachable** from the proxy subnets, and each backend's security group must allow inbound from the proxy/NLB. HAProxy health checks mark unreachable destinations down.
- Use at least two AZs for the NLB/endpoint service; cross-region serverless requires the endpoint service to span at least two AZs.
