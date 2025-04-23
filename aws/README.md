# Security Reference Architectures (SRA) - Terraform Templates

## Read Before Deploying
## Read Before Deploying

SRA is a purpose-built, simplified deployment pattern designed for highly secure and regulated customers.
SRA is a purpose-built, simplified deployment pattern designed for highly secure and regulated customers.

This architecture includes specific functionalities that may affect certain use cases, as outlined below.
This architecture includes specific functionalities that may affect certain use cases, as outlined below.

- **No outbound internet traffic**: There is no outbound internet from the classic compute plane, meaning there is no access to public package repositories, public APIs, and [Apache Derby](https://kb.databricks.com/metastore/set-up-embedded-metastore) configurations must be used on every classic compute cluster.
    - To add packages to classic compute plane clusters, set up a private repository for scanned packages.
    - Consider using a modern firewall solution to connect to public API endpoints.
    - An example cluster is provided with the correct Apache Derby configurations.

- **Restrictive AWS Resource Policies**: Restrictive endpoint policies have been implemented for the workspace root storage bucket, S3 gateway endpoint, STS interface endpoint, and Kinesis endpoint. These restrictions are refined continuously as the product evolves.
    - Policies can be adjusted to allow access to additional AWS resources, such as other S3 buckets.
    - If you encounter unexpected product behavior due to a policy in this repository, please raise a Git issue.

- **Isolated Unity Catalog Securables**: Unity Catalog securables like catalogs, Storage Credentials, and External Locations are isolated to individual workspaces.
    - To share securables between workspaces, update the resources using the [databricks_workspace_binding](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_binding) resource.

## Customizations

Terraform customizations are available to support the baseline deployment of the Security Reference Architecture (SRA). These customizations are organized by provider:

- **Account**: Databricks account provider.
- **Workspace**: Databricks workspace provider.
- **Networking Configuration**: AWS provider.

These extensions can be found in the top-level customization folder.

## SRA Component Breakdown and Description

In this section, we break down core components included in this Security Reference Architecture.

Various `.tf` scripts contain direct links to the Databricks Terraform documentation. You can find the [official documentation here](https://registry.terraform.io/providers/databricks/databricks/latest/docs).

### Network Configuration

Choose from two network configurations for your workspaces: **isolated** or **custom**.

- **Isolated (Default)**: Opting for 'isolated' prevents any traffic to the public internet, limiting traffic to AWS private endpoints for AWS services or the Databricks control plane.
   - **NOTE**: Apache Derby Metastore will be required for clusters and non-serverless SQL Warehouses. For more information, view this [knowledge article](https://kb.databricks.com/metastore/set-up-embedded-metastore).

- **Custom**: Selecting 'custom' allows you to specify your own VPC ID, subnet IDs, security group IDs, and PrivateLink endpoint IDs. This mode is recommended when networking assets are created in different pipelines or pre-assigned by a centralized infrastructure team.

### Core AWS Components

- **Customer-managed VPC**: A [customer-managed VPC](https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html) allows Databricks customers to exercise more control over network configurations to comply with specific cloud security and governance standards required by their organization.

- **S3 Buckets**: Two S3 buckets are created to support the following functionalities:
    - [Workspace Root Bucket](https://docs.databricks.com/en/admin/account-settings-e2/storage.html)
    - [Unity Catalog - Workspace Catalog](https://docs.databricks.com/en/catalogs/create-catalog.html)

- **IAM Roles**: Two IAM roles are created to support the following functionalities:
    - [Classic Compute (EC2) Provisioning](https://docs.databricks.com/en/admin/account-settings-e2/credentials.html)
    - [Data Access for Unity Catalog - Workspace Catalog](https://docs.databricks.com/en/connect/unity-catalog/cloud-storage/storage-credentials.html#step-1-create-an-iam-role)

- **AWS VPC Endpoints for S3, STS, and Kinesis**: Using AWS PrivateLink, a VPC endpoint connects a customer's VPC endpoint to AWS services without traversing public IP addresses. [S3, STS, and Kinesis endpoints](https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#step-5-add-vpc-endpoints-for-other-aws-services-recommended-but-optional) are best practices for enterprise Databricks deployments. Additional endpoints can be configured based on your use case (e.g., Amazon DynamoDB and AWS Glue).

- **Back-end AWS PrivateLink Connectivity**: AWS PrivateLink provides a private network route from one AWS environment to another. [Back-end PrivateLink](https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#overview) is configured so communication between the customer's data plane and the Databricks control plane does not traverse public IP addresses. This is accomplished through Databricks-specific interface VPC endpoints. Front-end PrivateLink is also available for customers to keep user traffic over the AWS backbone, though front-end PrivateLink is not included in this Terraform template.

- **Scoped-down IAM Policy for the Databricks cross-account role**: A [cross-account role](https://docs.databricks.com/administration-guide/account-api/iam-role.html) is needed for users, jobs, and other third-party tools to spin up Databricks clusters within the customer's data plane environment. This role can be scoped down to function only within the data plane's VPC, subnets, and security group.

- **AWS KMS Keys**: Three AWS KMS keys are created to support the following functionalities:
    - [Workspace Storage](https://docs.databricks.com/en/security/keys/customer-managed-keys.html#customer-managed-keys-for-workspace-storage)
    - [Managed Services](https://docs.databricks.com/en/security/keys/customer-managed-keys.html#customer-managed-keys-for-managed-services)
    - [Unity Catalog - Workspace Catalog](https://docs.databricks.com/en/connect/unity-catalog/cloud-storage/manage-external-locations.html#configure-an-encryption-algorithm-on-an-external-location)

### Core Databricks Components
### Core Databricks Components

- **Unity Catalog**: [Unity Catalog](https://docs.databricks.com/data-governance/unity-catalog/index.html) is a unified governance solution for data and AI assets, including files, tables, and machine learning models. It provides granular access controls with centralized policy, auditing, and lineage tracking—all integrated into the Databricks workflow.

- **System Tables Schemas**: [System Tables](https://docs.databricks.com/en/admin/system-tables/index.html) provide visibility into access, billing, compute, Lakeflow, query, serving, and storage logs. These tables can be found within the system catalog in Unity Catalog.

- **Cluster Example**: An example of a cluster and a cluster policy has been included. **NOTE:** Please be aware this will create a cluster within your Databricks workspace including the underlying EC2 instance.

<<<<<<< HEAD
- **IP Access Lists**: IP Access can be enabled to only allow a subset of IPs to access the Databricks workspace console. **NOTE:** Please verify all of the IPs are correct prior to enabling this feature to prevent a lockout scenario.
=======
- **Audit Log Delivery**: Low-latency delivery of Databricks logs to a S3 bucket in your AWS account. [Audit logs](https://docs.databricks.com/aws/en/admin/account-settings/audit-log-delivery) contain two levels of events: workspace-level audit logs with workspace-level events, and account-level audit logs with account-level events. Additionally, you can generate more detailed events by enabling verbose audit logs. 

---
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)

- **Read Only External Location**: This creates a read-only external location in Unity Catalog for a given bucket as well as the corresponding AWS IAM role.

- **Restrictive Root Bucket**: A restrictive root bucket policy can be applied to the root bucket of the workspace. **NOTE:** Please be aware this bucket is updated frequently, however, may not contain prefixes for the latest product releases.

- **Restrictive Kinesis, STS, and S3 Endpoint Policies**: Restrictive policies for Kinesis, STS, and S3 endpoints can be added for Databricks specific assets. **NOTE:** Please be aware thse policies could be updated and may result in potentially breaking changes. If this is the case, we recommend removing the policy.

- **System Tables**: System tables are a Databricks-hosted analytical store of your account’s operational data found in the system catalog. System tables can be used for historical observability across your account. This is currently in public preview, so is optional to enable or not.

- **Workspace Admin. Configurations**: Workspace administration configurations that can be enabled that align with security best practices. The Terraform resource is experimental, which is why it is optional. Documentation on each configuration is provided in the Terraform file.


## Solution Accelerators

- **Security Analysis Tool (SAT)**: The Security Analysis Tool analyzes customer's Databricks account and workspace security configurations and provides recommendations that can help them follow Databricks' security best practices. This can be enabled into the workspace that is being created. **NOTE:** Please be aware this creates a cluster, a job, and a dashboard within your environment. 

- **Audit Log Alerting**: Audit Log Alerting, based on this [blog post](https://www.databricks.com/blog/improve-lakehouse-security-monitoring-using-system-tables-databricks-unity-catalog), creates 40+ SQL alerts to monitor for incidents based on a Zero Trust Architecture (ZTA) model. **NOTE:** Please be aware this creates a cluster, a job, and queries within your environment. 

<<<<<<< HEAD
=======
- **Implement Restrictive Serverless Network Policy**: Serverless network policies can be found under Cloud resources, Network, in the account console. A network policy implements an egress firewall for your serverless compute. If you're using the Security Analysis Tool, be sure to allow list the Databricks account console and relevant Databricks workspace endpoints.

---
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)

## Additional Security Recommendations

This section provides additional security recommendations to help maintain a strong security posture. These cannot always be configured into this Terraform script or may be specific to individual customers (e.g., SCIM, SSO, Front-End PrivateLink, etc.)

- **Segment Workspaces for Data Separation**: This approach is particularly useful when teams such as security and marketing require distinct data access.
- **Avoid Storing Production Datasets in Databricks File Store**: The DBFS root is accessible to all users in a workspace. Specify a location on external storage when creating databases in the Hive metastore.
- **Backup Assets from the Databricks Control Plane**: Use tools such as the Databricks [migration tool](https://github.com/databrickslabs/migrate) or [Terraform exporter](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/experimental-exporter).
- **Regularly Restart Databricks Clusters**: Restart clusters periodically to ensure the latest compute resource images are used.
- **Evaluate Your Workflow for Git Repos or CI/CD Needs**: Integrate CI/CD for code scanning, permission control, and sensitive data detection.

---

## Getting Started

<<<<<<< HEAD
1. Clone this Repo
2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
3. Decide which [operation](https://github.com/databricks/terraform-databricks-sra/tree/main/aws/tf#operation-mode) mode you'd like to use.
4. Fill out `sra.tf` in place
5. Fill out `template.tfvars.example` remove the .example part of the file name
6. Configure the [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) and [Databricks](https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication) provider authentication
7. CD into `tf`
8. Run `terraform init`
9. Run `terraform validate`
10. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
11. Run `terraform apply -var-file ../example.tfvars`
=======
1. Clone this Repo.
2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads).
3. Decide which [operation mode](https://github.com/databricks/terraform-databricks-sra/tree/main/aws/tf#operation-mode) you'd like to use.
4. Fill out `main.tf`.
5. Fill out `template.tfvars.example` and rename the file to `template.tfvars` by removing `.example`.
6. Configure the [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) and [Databricks](https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication) provider authentication.
7. Change directory into `tf`.
8. Run `terraform init`.
9. Run `terraform validate`.
10. From the `tf` directory, run `terraform plan -var-file ../example.tfvars`.
11. Run `terraform apply -var-file ../example.tfvars`.
>>>>>>> a043e86 (Updated README)


## Network Diagram - Sandbox
![Architecture Diagram](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/img/Sandbox%20-%20Network%20Topology.png)


## Network Diagram - Firewall
![Architecture Diagram](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/img/Firewall%20-%20Network%20Topology.png)


## Network Diagram - Isolated
![Architecture Diagram](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/img/Isolated%20-%20Network%20Topology.png)