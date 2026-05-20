# Security Reference Architectures (SRA) - Terraform Templates

## Read Before Deploying

SRA is a purpose-built, simplified deployment pattern designed for highly secure and regulated customers.

This architecture includes specific functionalities that may affect certain use cases, as outlined below.

- **No outbound internet traffic**: There is no outbound internet access from the classic compute plane or serverless compute plane.
    - To add packages to classic compute or serverless compute, set up a private repository for scanned packages.
    - Consider using a modern firewall solution to connect to public API endpoints if public internet connectivity is required.

- **Restrictive AWS Resource Policies**: Restrictive endpoint policies have been implemented for the workspace root storage bucket, S3 gateway endpoint, STS interface endpoint, and Kinesis endpoint. These restrictions are continuously refined as the product evolves.
    - Policies can be adjusted to allow access to additional AWS resources, such as other S3 buckets.
    - If you encounter unexpected product behavior due to a policy in this repository, please raise a GitHub issue.

- **Isolated Unity Catalog Securables**: Unity Catalog securables like catalogs, Storage Credentials, and External Locations are isolated to individual workspaces.
    - To share securables between workspaces, update the resources using the [databricks_workspace_binding](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_binding) resource.

## Customizations

Terraform customizations are available to support the baseline deployment of the Security Reference Architecture (SRA). These customizations are organized by provider:

- **Workspace**: Databricks workspace provider.

These extensions can be found in the top-level customization folder.

## SRA Component Breakdown and Description

In this section, we break down the core components included in this Security Reference Architecture.

Various `.tf` scripts contain direct links to the Databricks Terraform documentation. You can find the [official documentation here](https://registry.terraform.io/providers/databricks/databricks/latest/docs).

### Network Configuration

Choose from two network configurations for your workspaces: **isolated** or **custom**.

- **Isolated (Default)**: Opting for 'isolated' prevents any traffic to the public internet, limiting traffic to AWS private endpoints for AWS services or the Databricks control plane.
   - **NOTE**: A Unity Catalog-only configuration is required for any clusters running without access to the public internet. Please see the official documentation [here](https://docs.databricks.com/aws/en/data-governance/unity-catalog/disable-hms).

- **Custom**: Selecting 'custom' allows you to specify your own VPC ID, subnet IDs, security group IDs, and PrivateLink endpoint IDs. This mode is recommended when networking assets are created in different pipelines or pre-assigned by a centralized infrastructure team.
    - **Bring AWS PrivateLink endpoint IDs**: Set `custom_general_access_vpce_id`, `custom_scc_relay_vpce_id`, and (optionally) `custom_service_direct_vpce_id`. SRA will register them with Databricks on your behalf.
    - **Bring already-registered Databricks MWS endpoint IDs**: Set `custom_general_access_mws_vpce_id`, `custom_scc_relay_mws_vpce_id`, and (optionally) `custom_service_direct_mws_vpce_id`. Use this path when the VPC endpoints have already been registered with the Databricks account (e.g., for sharing across multiple workspaces in the same VPC). SRA skips the registration step and wires these IDs straight into the workspace network configuration.

### Core AWS Components

- **Customer-managed VPC**: A [customer-managed VPC](https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html) allows Databricks customers to exercise more control over network configurations to comply with specific cloud security and governance standards required by their organization.

- **S3 Buckets**: Three S3 buckets are created to support the following functionalities:
    - [Workspace Root Bucket](https://docs.databricks.com/en/admin/account-settings-e2/storage.html)
    - [Unity Catalog - Workspace Catalog](https://docs.databricks.com/en/catalogs/create-catalog.html)
    - [Audit Log Delivery Bucket](https://docs.databricks.com/aws/en/admin/account-settings-e2/audit-aws-storage)

- **IAM Roles**: Three IAM roles are created to support the following functionalities:
    - [Classic Compute (EC2) Provisioning](https://docs.databricks.com/en/admin/account-settings-e2/credentials.html)
    - [Data Access for Unity Catalog - Workspace Catalog](https://docs.databricks.com/en/connect/unity-catalog/cloud-storage/storage-credentials.html#step-1-create-an-iam-role)
    - [Audit Log Delivery IAM Role](https://docs.databricks.com/aws/en/admin/account-settings-e2/audit-aws-credentials)

- **AWS VPC Endpoints for S3, STS, and Kinesis**: Using AWS PrivateLink, a VPC endpoint connects a customer's VPC to AWS services without traversing public IP addresses. [S3, STS, and Kinesis endpoints](https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#step-5-add-vpc-endpoints-for-other-aws-services-recommended-but-optional) are best practices for enterprise Databricks deployments. Additional endpoints can be configured based on your use case (e.g., Amazon DynamoDB and AWS Glue).
    - **NOTE**: Restrictive VPC endpoint policies have been implemented for S3, STS, and Kinesis. To access additional S3, STS, or Kinesis resources via the classic compute plane, please update these resources accordingly.
    - **NOTE**: These VPC endpoint policies are purpose-built for the bare minimum Databricks classic compute plane connectivity. For additional buckets, please update the S3 endpoint policy. For other resources, please update each endpoint as required.

- **Back-end AWS PrivateLink Connectivity**: AWS PrivateLink provides a private network route from one AWS environment to another. [Back-end PrivateLink](https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#overview) is configured so that communication between the customer's classic compute plane and the Databricks control plane does not traverse public IP addresses. This is accomplished through Databricks-specific interface VPC endpoints. Front-end PrivateLink is also available for customers to keep user traffic over the AWS backbone, though front-end PrivateLink is not included in this Terraform template.

- **Service Direct (opt-in)**: A front-end PrivateLink interface VPC endpoint that enables clients to reach the workspace UI/API privately. Service Direct endpoints are commonly shared across workspaces in the same VPC, so SRA does not create one by default. Set `create_service_direct_vpce = true` to have SRA create and register a new Service Direct endpoint for this deployment. Not available in GovCloud regions.

- **Scoped-down IAM Policy for the Databricks cross-account role**: A [cross-account role](https://docs.databricks.com/administration-guide/account-api/iam-role.html) is needed for users, jobs, and other third-party tools to spin up Databricks clusters within the customer's classic compute plane. This role can be scoped down to function only within the classic compute plane's VPC, subnets, and security group.

- **AWS KMS Keys**: Three AWS KMS keys are created to support the following functionalities:
    - [Workspace Storage](https://docs.databricks.com/en/security/keys/customer-managed-keys.html#customer-managed-keys-for-workspace-storage)
    - [Managed Services](https://docs.databricks.com/en/security/keys/customer-managed-keys.html#customer-managed-keys-for-managed-services)
    - [Unity Catalog - Workspace Catalog](https://docs.databricks.com/en/connect/unity-catalog/cloud-storage/manage-external-locations.html#configure-an-encryption-algorithm-on-an-external-location)

### Core Databricks Components

- **Unity Catalog**: [Unity Catalog](https://docs.databricks.com/data-governance/unity-catalog/index.html) is a unified governance solution for data and AI assets, including files, tables, and machine learning models. It provides granular access controls with centralized policy, auditing, and lineage tracking—all integrated into the Databricks workflow.

- **System Tables Schemas**: [System Tables](https://docs.databricks.com/en/admin/system-tables/index.html) provide visibility into access, compute, Lakeflow, query, serving, and storage logs. These tables can be found within the system catalog in Unity Catalog.

- **Cluster Example**: An example cluster and cluster policy. **NOTE:** This will create a cluster within your Databricks workspace, including the underlying EC2 instance.

- **Audit Log Delivery**: Low-latency delivery of Databricks logs to an S3 bucket in your AWS account. [Audit logs](https://docs.databricks.com/aws/en/admin/account-settings/audit-log-delivery) contain two levels of events: workspace-level audit logs with workspace-level events, and account-level audit logs with account-level events. Additionally, you can generate more detailed events by enabling verbose audit logs. 
   - **NOTE**: Audit log delivery can only be configured twice for a single account. It's recommended that once it is configured, you set *audit_log_delivery_exists* = *true* for subsequent runs.

- **Restrictive Network Policy**: [Network policies](https://docs.databricks.com/aws/en/security/network/serverless-network-security/manage-network-policies) provide egress controls for serverless compute. A restrictive network policy is implemented on the workspace, allowing outbound traffic only to required data buckets.

### SRA Usage Telemetry

Each Databricks provider block sets `user_agent_extra = "terraform-databricks-sra/aws/v${local.sra_version}"`. This tag is appended to the `User-Agent` HTTP header on Databricks API calls so Databricks can measure SRA adoption. No additional data is collected — just the tag string. To opt out, override the `user_agent_extra` value in your local copy of the provider block.

### Optional Naming Overrides

By default the workspace and Unity Catalog metastore are named from `resource_prefix` and `region`. Two optional tfvars let you override those names without changing `resource_prefix`:

- `workspace_display_name`: Human-readable workspace name shown in the Databricks UI. Defaults to `resource_prefix` when unset.
- `custom_metastore_name`: Name of the Unity Catalog metastore created by this deployment. Defaults to `${var.region}-unity-catalog` when unset. Only used when `metastore_exists = false`.

---

## Critical Next Steps

- **Implement a Front-End Mitigation Strategy**:
    - [IP Access Lists](https://docs.databricks.com/en/security/network/front-end/ip-access-list.html): The Terraform code for enabling IP access lists can be found in the customization folder.
    - [Front-End PrivateLink](https://docs.databricks.com/en/security/network/classic/privatelink.html#step-5-configure-internal-dns-to-redirect-user-requests-to-the-web-application-front-end).

- **Implement Single Sign-On, Multi-Factor Authentication, and SCIM Provisioning**: Most enterprise deployments enable [Single Sign-On (SSO)](https://docs.databricks.com/administration-guide/users-groups/single-sign-on/index.html) and multi-factor authentication (MFA). For user management, we recommend integrating [SCIM (System for Cross-domain Identity Management)](https://docs.databricks.com/dev-tools/api/latest/scim/index.html) with your account console.

---

## Govcloud Deployments

- **Region**: `region` must be set as `us-gov-west-1`.
- **Govcloud Shard**: `databricks_gov_shard` must be either `civilian` or `dod`. For all non-govcloud deployments (commercial regions) `databricks_gov_shard` should remain null.
    - **NOTE**: `dod` is only available to customers with a .mil email address.

---

## Additional Security Recommendations

This section provides additional security recommendations to help maintain a strong security posture. These cannot always be configured in this Terraform script or may be specific to individual customers (e.g., SCIM, SSO, Front-End PrivateLink, etc.).

- **Segment Workspaces for Data Separation**: This approach is particularly useful when teams such as security and marketing require distinct data access.
- **Avoid Storing Production Datasets in Databricks File Store**: The DBFS root is accessible to all users in a workspace. Specify a location on external storage when creating databases in the Hive metastore.
- **Back Up Assets from the Databricks Control Plane**: Use tools such as the Databricks [migration tool](https://github.com/databrickslabs/migrate) or [Terraform exporter](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/experimental-exporter).
- **Regularly Restart Databricks Clusters**: Restart clusters periodically to ensure the latest compute resource images are used.
- **Evaluate Your Workflow for Git Repos or CI/CD Needs**: Integrate CI/CD for code scanning, permission control, and sensitive data detection.

---

## Getting Started

1. Clone this repository.
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

---

## Network Diagram

![Architecture Diagram](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/img/Isolated%20-%20Network%20Topology.png)