#### Audit Log Alerting: 
Audit Log Alerting, based on this [blog post](https://www.databricks.com/blog/improve-lakehouse-security-monitoring-using-system-tables-databricks-unity-catalog), creates 40+ SQL alerts to monitor incidents using a Zero Trust Architecture (ZTA) model.

- **NOTE:** Enabling this feature will create a cluster, a job, and queries within your environment.

### How to add this resource to SRA:

1. Copy the `system_tables_audit_log` folder into `modules/databricks_workspace/` 
2. Add the following code block into `modules/databricks_workspace.tf`
```
module "system_tables_audit_log" {
  source = "./modules/databricks_workspace/system_tables_audit_log/"
  providers = {
    databricks = databricks.created_workspace
  }

  alert_emails = [var.admin_user]

  depends_on = [
    module.databricks_mws_workspace, module.uc_assignment
  ]
}
```
3. Run `terraform init`
4. Run `terraform validate`
5. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`