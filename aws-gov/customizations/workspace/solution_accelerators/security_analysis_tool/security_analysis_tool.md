### Security Analysis Tool (SAT): 
The Security Analysis Tool analyzes a customer’s Databricks account and workspace security configurations and provides recommendations to help them follow Databricks’ security best practices. This tool can be enabled in the workspace being created.

- **NOTE:** Enabling this tool will create a cluster, a job, and a dashboard within your environment.

### How to add this resource to SRA:

1. Copy the `security_analysis_tool` folder into `modules/sra/databricks_workspace/` 
2. Add the following code block into `modules/sra/databricks_workspace.tf`
```
module "security_analysis_tool" {
  source = "./databricks_workspace/security_analysis_tool/aws"
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_url       = module.databricks_mws_workspace.workspace_url
  workspace_id         = module.databricks_mws_workspace.workspace_id
  account_console_id   = var.databricks_account_id
  client_id            = var.client_id
  client_secret        = var.client_secret
  use_sp_auth          = true
  proxies              = {}
  analysis_schema_name = "SAT"

  depends_on = [
    module.databricks_mws_workspace
  ]
}
```
3. Run `terraform init`
4. Run `terraform validate`
5. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`