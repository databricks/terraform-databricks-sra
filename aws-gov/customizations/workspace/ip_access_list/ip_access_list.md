### IP Access Lists
IP Access can be enabled to restrict access to the Databricks workspace console to a specified subset of IPs.
- **NOTE:** Verify that all IPs are correct before enabling this feature to prevent a lockout scenario.


### How to add this resource to SRA:

1. Copy the `ip_access_list` folder into `modules/sra/databricks_workspace/` 
2. Add the following code block into `modules/sra/databricks_workspace.tf`
```
module "ip_access_list" {
    source = "./databricks_workspace/ip_access_list"
    providers = {
    databricks = databricks.created_workspace
  }

    ip_addresses = <list(string) of IP addresses>
}
```
3. Run `terraform init`
4. Run `terraform validate`
5. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`
