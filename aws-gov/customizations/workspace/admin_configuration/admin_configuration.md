### **Workspace Admin. Configurations**: 
Workspace administration configurations can be enabled to align with security best practices. This Terraform resource is experimental, making it optional. Documentation for each configuration is provided in the Terraform file.

### How to add this resource to SRA:

1. Copy the `admin_configuration` folder into `modules/sra/databricks_workspace/` 
2. Add the following code block into `modules/sra/databricks_workspace.tf`
```
module "admin_configuration" {
  source = "./databricks_workspace/admin_configuration"
  providers = {
    databricks = databricks.created_workspace
  }
}
```
3. Run `terraform init`
4. Run `terraform validate`
5. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
6. Run `terraform apply -var-file ../example.tfvars`