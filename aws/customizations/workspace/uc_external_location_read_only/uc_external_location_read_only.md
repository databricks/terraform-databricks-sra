### Read-Only External Location
This creates a read-only external location in Unity Catalog for a specified bucket, along with the corresponding AWS IAM role.


### How to add this resource to SRA:

1. Copy the `uc_external_location_read_only` folder into `modules/sra/databricks_workspace/` 
2. Add the following code block into `modules/sra/databricks_workspace.tf`
```
module "uc_external_location_read_only" {
  source = "./databricks_workspace/uc_external_location_read_only"
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_account_id             = var.databricks_account_id
  aws_account_id                    = var.aws_account_id
  resource_prefix                   = var.resource_prefix
  read_only_data_bucket             = <bucket_name>
  read_only_external_location_admin = <admin_email>
}
```
3. Run `terraform init`
4. Run `terraform validate`
5. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`