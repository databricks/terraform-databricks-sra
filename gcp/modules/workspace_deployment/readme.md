---
page_title: "Workspace Deployment GCP SRA Module"
---

# Module to deploy a Databricks workspace on GCP

This module provisions a Databricks workspace on Google Cloud. It supports:

- **Classic and serverless** workspaces.
- **Create-from-scratch** or **bring-your-own** for VPC, PSC endpoints, Private Access Settings, CMEK keys, and DNS zones.
- **Three DNS modes** for PSC workspaces: module creates zone + records, module creates records in an existing zone, or module creates nothing (manual DNS).
- **Hardened network** with optional firewall rules.
- **Workspace hardening** (IP access lists, verbose audit logs, DBFS file browser disabled, 90-day token lifetime).
- **Optional resource_owner admin assignment** at the workspace level.

## Requirements

- Recent version of Terraform (>= 1.5 recommended).
- Databricks provider `>= 1.113.0` and Google provider `>= 5.43.1`.
- A Google Service Account with the IAM roles required by the `service_account` module and added to the Databricks Account Console as an account admin.
- A GCS bucket to hold remote state (the backend is configured as `gcs` — see `providers.tf`).

## Remote state (GCS)

The module declares a partial `gcs` backend. Provide the bucket/prefix at `terraform init` time, e.g.:

```bash
terraform init \
  -backend-config="bucket=my-tfstate-bucket" \
  -backend-config="prefix=databricks/workspace_deployment"
```

If you want to use a different backend, override `providers.tf` in your consuming configuration or remove the `backend "gcs" {}` block.

## Resource naming

All module-created resources use the format:

```
<resource_prefix>-<resource>-<deployment_suffix>
```

- `resource_prefix` defaults to `databricks` and is configurable via `var.resource_prefix`.
- `deployment_suffix` is a random 6-char alphanumeric string generated once and stored in state.

## Variables

### General

- `databricks_account_id` — Databricks account ID.
- `databricks_google_service_account` — Service account used to impersonate.
- `google_project`, `google_region` — GCP project and region.
- `account_console_url` — Defaults to `https://accounts.gcp.databricks.com`.
- `workspace_name` — Name of the workspace to create.
- `resource_prefix` — Prefix for all resources. Defaults to `databricks`.

### Compute mode

- `serverless_workspace_deployment` — When `true`, skips all VPC/PSC/network configuration and deploys a serverless workspace.

### Networking

- `use_existing_vpc` — Reuse an existing VPC.
- `existing_vpc_name`, `existing_subnet_name` — Required when `use_existing_vpc = true`.
- `nodes_ip_cidr_range` — CIDR for nodes (immutable after creation).
- `harden_network` — Enables a set of egress/ingress firewall rules. A new `db-<subnet>-ingress` rule is created (for non-serverless, non-BYO-VPC deployments only) so that Databricks does not create its own firewall rule. When `use_existing_vpc = true` the module creates **no** GCP firewalls — you are responsible for providing the rules Databricks requires on the VPC you bring.
- `databricks_control_plane_ips` — Regional control-plane IPs used in the egress firewall rule when `harden_network = true` and `use_psc = false`. Look up the values for your region at [IP addresses and domains](https://docs.databricks.com/gcp/en/resources/ip-domain-region).

### PSC / connectivity

- `use_psc` — Enable backend Private Service Connect.
- `use_frontend_psc` — Enable frontend Private Service Connect.
- `use_existing_PSC_EP`, `existing_workspace_psc_endpoint_ip` — Reuse an existing PSC endpoint and its IP.
- `workspace_pe`, `relay_pe`, `workspace_pe_ip_name`, `relay_pe_ip_name`, `workspace_service_attachment`, `relay_service_attachment` — PSC-related names and attachments.
- `google_pe_subnet_ip_cidr_range` — CIDR for the PSC endpoint subnet.
- `use_existing_databricks_vpc_eps`, `existing_databricks_vpc_ep_workspace`, `existing_databricks_vpc_ep_relay` — Reuse existing Databricks VPC endpoints.
- `use_existing_pas`, `existing_pas_id` — Reuse an existing Private Access Settings.

### DNS (three modes)

| `create_dns_zone` | `existing_dns_zone_name` | Behavior |
|---|---|---|
| `true` | ignored | Module creates a private DNS zone (`var.dns_zone_name`) for `gcp.databricks.com.` and writes workspace + tunnel A-records into it. |
| `false` | set | Module writes A-records into the existing zone you provide. |
| `false` | empty (default) | Module creates nothing — you manage DNS manually. |

When DNS is managed (mode 1 or 2), the module creates **three** A-records:

| Record | Points to | Purpose |
|---|---|---|
| `<workspace_id>.<shard>.gcp.databricks.com.` | Workspace PSC IP | Workspace web UI and REST API |
| `dp-<workspace_id>.<shard>.gcp.databricks.com.` | Workspace PSC IP | Data plane workspace URL |
| `tunnel.<region>.gcp.databricks.com.` | Relay PSC IP | SCC relay — cluster VMs use this to establish the secure tunnel back to the control plane |

Variables:

- `create_dns_zone` — defaults to `false`.
- `dns_zone_name` — defaults to `databricks-private-zone`.
- `existing_dns_zone_name` — defaults to `""`.
- `existing_relay_psc_endpoint_ip` — IP of an existing relay PSC endpoint (only needed when `use_existing_PSC_EP = true`).

> **Important — Private Google Access and `googleapis.com` DNS:**
> PSC workspaces require the VPC to have access to Google APIs (GCS, IAM, KMS,
> Container Registry, etc.) via Private Google Access. This module enables
> `private_ip_google_access = true` on the workspace subnet it creates, and the
> hardened firewall allows egress to `199.36.153.4/30` (restricted Google APIs).
>
> However, **you must also ensure that the VPC can resolve `*.googleapis.com`
> to the restricted (or private) Google APIs range**. If your VPC does not
> have a private DNS zone for `googleapis.com` pointing to `199.36.153.4/30`
> (restricted) or `199.36.153.8/30` (private), the cluster VMs will fail to
> reach GCS and other Google services during bootstrap — even though the
> firewall allows the traffic.
>
> This module does **not** create the `googleapis.com` DNS zone because it is
> typically shared across all workloads in a VPC, not scoped to a single
> Databricks workspace. You can create it with:
>
> ```hcl
> resource "google_dns_managed_zone" "googleapis" {
>   name        = "googleapis"
>   project     = var.google_project
>   dns_name    = "googleapis.com."
>   visibility  = "private"
>   private_visibility_config {
>     networks { network_url = google_compute_network.your_vpc.self_link }
>   }
> }
> resource "google_dns_record_set" "googleapis_a" {
>   project      = var.google_project
>   name         = "restricted.googleapis.com."
>   type         = "A"
>   ttl          = 300
>   managed_zone = google_dns_managed_zone.googleapis.name
>   rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
> }
> resource "google_dns_record_set" "googleapis_cname" {
>   project      = var.google_project
>   name         = "*.googleapis.com."
>   type         = "CNAME"
>   ttl          = 300
>   managed_zone = google_dns_managed_zone.googleapis.name
>   rrdatas      = ["restricted.googleapis.com."]
> }
> ```
>
> For BYO-VPC deployments, verify this zone already exists in your VPC before
> deploying with PSC + hardened network.

### CMEK

- `use_cmek` — Master flag (defaults to `false`).
- `use_existing_cmek` — Reuse an existing CMEK; requires `cmek_resource_id`.
- `key_name`, `keyring_name` — Names used when creating a new CMEK.
- `cmek_resource_id` — Full resource ID of an existing CMEK.

### Admin assignment

- `resource_owner` — Email of a user to be granted workspace ADMIN.
- `skip_user_lookup` — Set `true` during destroy if the user no longer exists.

### Unity Catalog / Metastore

- `regional_metastore_id` — If set, the workspace is attached to this metastore.
- `default_catalog_name` — Existing catalog to set as the workspace's default namespace. Defaults to `"default_catalog"` (the Databricks auto-created catalog). Set to any other existing catalog name to point the workspace at it, or `""` to skip managing the default namespace. **The module does not create the catalog** — it must already exist in the metastore.

## Outputs

- `workspace_url` — Workspace URL.
- `workspace_id` — Workspace ID.
- `workspace_name` — Workspace name.
- `region` — GCP region.
- `deployment_suffix` — Random suffix used for resource naming.
- `databricks_host` — Deprecated alias for `workspace_url`.

## Upgrading from a previous version of this module

This revision renames most module-managed GCP resources to a uniform
`${resource_prefix}-<resource>-${deployment_suffix}` scheme (e.g. the VPC went
from `databricks-workspace-vpc-<suffix>` to `databricks-vpc-<suffix>`). The
random suffix length was preserved (6 chars) so the **suffix itself does not
change**, but the names still differ.

If you have an existing state, `terraform plan` will show those resources being
destroyed and recreated — which would tear the workspace down. You have two
options:

1. **Accept the recreation** (simplest). Destroy and redeploy in a maintenance
   window.
2. **Preserve state with `terraform state mv`**. For every renamed resource,
   rename the address in state, e.g.:

   ```bash
   terraform state mv \
     'module.customer_managed_vpc.google_compute_network.dbx_private_vpc[0]' \
     'module.customer_managed_vpc.google_compute_network.dbx_private_vpc[0]'   # no-op example
   ```

   and update the GCP resource name via a one-off `terraform apply` + API
   rename, or simply set `var.resource_prefix` to `"databricks-workspace"` (for
   VPC/subnet) — note that router/NAT/PAS/PE-subnet/network-config names still
   differ and cannot be reconciled without state surgery.

For brand-new deployments, no migration is required.
