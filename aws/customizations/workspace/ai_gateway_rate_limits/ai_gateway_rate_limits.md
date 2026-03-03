### AI Gateway Rate Limits
This module sets the provisioned model units to 0 for all serving endpoints in a Databricks workspace, effectively limiting their throughput.


### How to add this resource to SRA:

1. Copy the `ai_gateway_rate_limits` folder into `aws/tf/modules/databricks_workspace/` 
2. Add the following code block into `aws/tf/main.tf`
```
module "ai_gateway_rate_limits" {
  source = "./modules/databricks_workspace/ai_gateway_rate_limits"
  providers = {
    databricks = databricks.created_workspace
  }
}
```
3. Run `terraform init`
4. Run `terraform validate`
5. From `aws/tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`
