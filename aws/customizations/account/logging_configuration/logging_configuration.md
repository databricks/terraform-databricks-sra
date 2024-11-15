### Audit and Billable Usage Logs: 
Databricks delivers logs to your S3 buckets. [Audit logs](https://docs.databricks.com/administration-guide/account-settings/audit-logs.html) contain two levels of events: workspace-level audit logs with workspace-level events, and account-level audit logs with account-level events. Additionally, you can generate more detailed events by enabling verbose audit logs. [Billable usage logs](https://docs.databricks.com/administration-guide/account-settings/billable-usage-delivery.html) are delivered daily to an AWS S3 storage bucket. A separate CSV file is created for each workspace, containing historical data about the workspace’s cluster usage in Databricks Units (DBUs).

### How to add this resource to SRA:

1. Copy the `logging_configuration` folder into `modules/sra/databricks_account/` 
2. Add the following code block into `modules/sra/databricks_account.tf`
```
module "log_delivery" {
  source = "./databricks_account/logging_configuration"
  count  = var.enable_logging_boolean ? 1 : 0
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
}
```
3. Run `terraform init`
4. Run `terraform validate`
5. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`
