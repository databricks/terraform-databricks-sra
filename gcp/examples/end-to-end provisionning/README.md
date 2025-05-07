# End-to-End Provisioning Example

This Terraform example provides an opinionated and secure deployment of Databricks on Google Cloud Platform (GCP) with minimal setup. It is designed to help users quickly and efficiently deploy a secure Databricks environment following best practices.

## Features

- Automated provisioning of Databricks resources.
- Secure configuration aligned with industry standards.
- Minimal input required for deployment.

## Prerequisites

- Terraform installed on your local machine.
- Access to a GCP project with the necessary permissions.
- Basic understanding of Terraform and Databricks.
- Quota for Private Service Connect connectivity

## Usage

1. Clone this repository.
2. Navigate to the `gcp/examples/end-to-end-provisioning` directory.
3. Update the `terraform.tfvars` file with your configuration values.
4. Run the following commands:
    ```bash
    terraform init
    terraform apply
    ```
5. Confirm the deployment and wait for the resources to be provisioned.

## Notes

- This example is intended for demonstration purposes and may require adjustments for production use.
- Ensure you review and customize the configuration to meet your specific requirements.

## Cleanup

To destroy the resources created by this example, run:
```bash
terraform destroy
```

## Support

For questions or issues, please open an issue in this repository.