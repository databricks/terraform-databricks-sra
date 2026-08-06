### AI Gateway Rate Limits

This customization applies one endpoint-level AI Gateway request limit to every existing model-serving endpoint in a Databricks workspace, except endpoints explicitly excluded by name. It does not configure provisioned model units.

Use the `ai_gateway.rate_limits` block on `databricks_model_serving` instead when Terraform owns the endpoint. This customization is intended as a workspace-wide catch-all for endpoints that may be created outside Terraform.

The customization invokes the Databricks CLI because the provider cannot independently patch AI Gateway settings on an endpoint it does not manage. The machine running Terraform must have the current Databricks CLI installed, and the CLI inherits the same authentication environment used by the Databricks provider.

> [!WARNING]
> Setting `endpoint_rate_limit_calls = 0` blocks all requests to every managed endpoint. The module rejects zero unless `allow_zero_calls = true` is also set.

### Add the customization to SRA

1. Copy the `ai_gateway_rate_limits` folder into `aws/tf/modules/databricks_workspace/`.
2. Add the following code block into `aws/tf/main.tf`

```hcl
module "ai_gateway_rate_limits" {
  source = "./modules/databricks_workspace/ai_gateway_rate_limits"

  providers = {
    databricks = databricks.created_workspace
  }

  endpoint_rate_limit_calls = 60

  # Optional: endpoints managed separately or intentionally unrestricted.
  excluded_endpoint_names = ["example-endpoint"]
}
```

3. Run `terraform init`
4. Run `terraform validate`
5. From `aws/tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`

### Reconciliation behavior

- A newly discovered endpoint creates a new `terraform_data` instance and receives the configured limit.
- Changing the call limit, renewal period, or `enforcement_revision` replaces each managed instance and reapplies the configuration.
- The serving-endpoints API does not expose these remote settings through this Terraform resource, so Terraform cannot automatically detect out-of-band drift. Increment `enforcement_revision` to force reapplication after suspected drift.
- Removing or excluding an endpoint removes only the local `terraform_data` instance. It does not remove the endpoint's remote AI Gateway configuration.
