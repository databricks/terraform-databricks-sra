# Security Reference Architecture Template


## Introduction

Databricks has worked with thousands of customers to securely deploy the Databricks platform with appropriate security features to meet their architecture requirements.

This Security Reference Architecture (SRA) repository implements common security features as a unified terraform templates that are typically deployed by our security conscious customers.


## Component Breakdown and Description

In this section, we break down each of the components that we've included in this Security Reference Architecture.

In various `.tf` scripts, we have included direct links to the Databricks Terraform documentation. The [official documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs) can be found here.


## Operation Mode:

There are four separate operation modes you can choose for the underlying network configurations of your workspaces: **sandbox**, **firewall**, **isolated**, and **custom**. 

- **Sandbox**: Sandbox or open egress. Selecting 'sandbox' as the operation mode allows traffic to flow freely to the public internet. This mode is suitable for sandbox or development scenarios where data exfiltration protection is of minimal concern, and developers need to access public APIs, packages, and more.

- **Firewall**: Firewall or limited egress. Choosing 'firewall' as the operation mode permits traffic flow only to a selected list of public addresses. This mode is applicable in situations where open internet access is necessary for certain tasks, but unfiltered traffic is not an option due to the sensitivity of the workloads or data. **NOTE**: Due to a limitation in the AWS Network Firewall's ability to use fully qualified domain names for non-HTTP/HTTPS traffic, an external data source is required for the external Hive metastore. For production scenarios, we recommend using Unity Catalog or self-hosted Hive metastores.

- **Isolated**:  Isolated or no egress. Opting for 'isolated' as the operation mode prevents any traffic to the public internet. Traffic is limited to AWS private endpoints, either to AWS services or the Databricks control plane. This mode should be used in cases where access to the public internet is completely unsupported. **NOTE**: Apache Derby Metastore will be required for clusters and non-serverless SQL Warehouses. For more information, please view this [knowledge article](https://kb.databricks.com/metastore/set-up-embedded-metastore).

- **Custom**: Custom or bring your own network. Selecting 'custom' allows you to input your own details for a VPC ID, subnet IDs, security group IDs, and PrivateLink endpoint IDs. This mode is recommended when networking assets are created in different pipelines or are pre-assigned to a team by a centralized infrastructure team.

See the below networking diagrams for more information.


## Infrastructure Deployment

- **Customer-managed VPC**: A [customer-managed VPC](https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html) allows Databricks customers to exercise more control over network configuration to comply with specific cloud security and governance standards that a customer's organization may require.

- **AWS VPC Endpoints for S3, STS, and Kinesis**: Using AWS PrivateLink technology, a VPC endpoint is a service that connects a customer's VPC endpoint to AWS services without traversing public IP addresses. [S3, STS, and Kinesis endpoints](https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#step-5-add-vpc-endpoints-for-other-aws-services-recommended-but-optional) are best practices for standard enterprise Databricks deployments. Additional endpoints can be configured depending on use case (e.g. Amazon DynamoDB and AWS Glue).

- **Back-end AWS PrivateLink Connectivity**: AWS PrivateLink provides a private network route from one AWS environment to another. [Back-end PrivateLink](https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html#overview) is configured so that communication between the customer's data plane and the Databricks control plane does not traverse public IP addresses. This is accomplished through Databricks specific interface VPC endpoints. Front-end PrivateLink is available as well for customers to ensure users traffic remains over the AWS backbone. However front-end PrivateLink is not included in this Terraform template.

- **Scoped-down IAM Policy for the Databricks cross-account role**: A [cross-account role](https://docs.databricks.com/administration-guide/account-api/iam-role.html) is needed for users, jobs, and other third-party tools to spin up Databricks clusters within the customer's data plane environment. This cross-account role can be scoped down to only function within the parameters of the data plane's VPC, subnets, and security group.

- **Restrictive Root Bucket**: Each workspace, prior to creation, registers a [dedicated S3 bucket](https://docs.databricks.com/administration-guide/account-api/aws-storage.html). This bucket is for workspace assets. On AWS, S3 bucket policies can be applied to limit access to the Databricks control plane and the customer data plane.

- **Unity Catalog**: [Unity Catalog](https://docs.databricks.com/data-governance/unity-catalog/index.html) is a unified governance solution for all data and AI assets including files, tables, and machine learning models. Unity Catalog provides a modern approach to granular access controls with centralized policy, auditing, and lineage tracking - all integrated into your Databricks workflow. **NOTE**: SRA creates a workspace specific catalog that is isolated to that individual workspace. To change these settings please update uc_catalog.tf under the workspace_security_modules.


## Post Workspace Deployment

- **Service Principals**: A [Service principal](https://docs.databricks.com/administration-guide/users-groups/service-principals.html) is an identity that you create in Databricks for use with automated tools, jobs, and applications. It's against best practice to tie production workloads to individual user accounts, and so we recommend configuring these service principals within Databricks. In this template, we create an example service principal.

- **Token Management**: [Personal access tokens](https://docs.databricks.com/dev-tools/api/latest/authentication.html) are used to access Databricks REST APIs in-lieu of passwords. In this template we create an example token and set its time-to-live. This can be set at an administrative level for all users.

- **Secret Management** Integrating with heterogenous systems requires managing a potentially large set of credentials and safely distributing them across an organization. Instead of directly entering your credentials into a notebook, use [Databricks secrets](https://docs.databricks.com/security/secrets/index.html) to store your credentials and reference them in notebooks and jobs. In this template, we create an example secret.


## Optional Deployment Configurations

- **Audit and Billable Usage Logs**: Databricks delivers logs to your S3 buckets. [Audit logs](https://docs.databricks.com/administration-guide/account-settings/audit-logs.html) contain two levels of events: workspace-level audit logs with workspace-level events and account-level audit logs with account-level events. In addition to these logs, you can generate additional events by enabling verbose audit logs. [Billable usage logs](https://docs.databricks.com/administration-guide/account-settings/billable-usage-delivery.html) are delivered daily to an AWS S3 storage bucket. There will be a separate CSV file for each workspace. This file contains historical data about the workspace's cluster usage in Databricks Units (DBUs).

- **Cluster Example**: An example of a cluster and a cluster policy has been included. **NOTE:** Please be aware this will create a cluster within your Databricks workspace including the underlying EC2 instance.

- **IP Access Lists**: IP Access can be enabled to only allow a subset of IPs to access the Databricks workspace console. **NOTE:** Please verify all of the IPs are correct prior to enabling this feature to prevent a lockout scenario.

- **Read Only External Location**: This creates a read-only external location in Unity Catalog for a given bucket as well as the corresponding AWS IAM role.

- **Restrictive Root Bucket**: A restrictive root bucket policy can be applied to the root bucket of the workspace. **NOTE:** Please be aware this bucket is updated frequently, however, may not contain prefixes for the latest product releases.

- **Restrictive Kinesis, STS, and S3 Endpoint Policies**: Restrictive policies for Kinesis, STS, and S3 endpoints can be added for Databricks specific assets. **NOTE:** Please be aware thse policies could be updated and may result in potentially breaking changes. If this is the case, we recommend removing the policy.

- **System Tables**: System tables are a Databricks-hosted analytical store of your account’s operational data found in the system catalog. System tables can be used for historical observability across your account. This is currently in public preview, so is optional to enable or not.

- **Workspace Admin. Configurations**: Workspace administration configurations that can be enabled that align with security best practices. The Terraform resource is experimental, which is why it is optional. Documentation on each configuration is provided in the Terraform file.


## Solution Accelerators

- **Security Analysis Tool (SAT)**: The Security Analysis Tool analyzes customer's Databricks account and workspace security configurations and provides recommendations that can help them follow Databricks' security best practices. This can be enabled into the workspace that is being created. **NOTE:** Please be aware this creates a cluster, a job, and a dashboard within your environment. 

- **Audit Log Alerting**: Audit Log Alerting, based on this [blog post](https://www.databricks.com/blog/improve-lakehouse-security-monitoring-using-system-tables-databricks-unity-catalog), creates 40+ SQL alerts to monitor for incidents based on a Zero Trust Architecture (ZTA) model. **NOTE:** Please be aware this creates a cluster, a job, and queries within your environment. 


## Public Preview Features

- **System Tables Schemas**: System Table schemas are currently in private preview. System Tables provide visiblity into access, billing, compute, and storage logs. In this deployment the metastore admin, service principle, owns the table. Additional grant statements will be needed. **NOTE:** Please note this is currently in public preview.


## Additional Security Recommendations and Opportunities

In this section, we break down additional security recommendations and opportunities to maintain a strong security posture that either cannot be configured into this Terraform script or is very specific to individual customers (e.g. SCIM, SSO, Front-End PrivateLink, etc.)

- **Segement Workspaces for Various Levels of Data Seperation**: While Databricks has numerous capabilities for isolating different workloads, such as table ACLs and IAM passthrough for very sensitive workloads, the primary isolation method is to move sensitive workloads to a different workspace. This sometimes happens when a customer has very different teams (for example, a security team and a marketing team) who must both analyze different data in Databricks.

- **Avoid Storing Production Datasets in Databricks File Store**: Because the DBFS root is accessible to all users in a workspace, all users can access any data stored here. It is important to instruct users to avoid using this location for storing sensitive data. The default location for managed tables in the Hive metastore on Databricks is the DBFS root; to prevent end users who create managed tables from writing to the DBFS root, declare a location on external storage when creating databases in the Hive metastore.

- **Single Sign-On, Multi-factor Authentication, SCIM Provisioning**: Most production or enterprise deployments enable their workspaces to use [Single Sign-On (SSO)](https://docs.databricks.com/administration-guide/users-groups/single-sign-on/index.html) and multi-factor authentication (MFA). As users are added, changed, and deleted, we recommended customers integrate [SCIM (System for Cross-domain Identity Management)](https://docs.databricks.com/dev-tools/api/latest/scim/index.html)to their account console to sync these actions.

- **Backup Assets from the Databricks Control Plane**: While Databricks does not offer disaster recovery services, many customers use Databricks capabilities, including the Account API, to create a cold (standby) workspace in another region. This can be done using various tools such as the Databricks [migration tool](https://github.com/databrickslabs/migrate), [Databricks sync](https://github.com/databrickslabs/databricks-sync), or the [Terraform exporter](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/experimental-exporter)

- **Regularly Restart Databricks Clusters**: When you restart a cluster, it gets the latest images for the compute resource containers and the VM hosts. It is particularly important to schedule regular restarts for long-running clusters such as those used for processing streaming data. If you enable the compliance security profile for your account or your workspace, long-running clusters are automatically restarted after 25 days. Databricks recommends that admins restart clusters manually during a scheduled maintenance window. This reduces the risk of an auto-restart disrupting a scheduled job.

- **Evaluate Whether your Workflow requires using Git Repos or CI/CD**: Mature organizations often build production workloads by using CI/CD to integrate code scanning, better control permissions, perform linting, and more. When there is highly sensitive data analyzed, a CI/CD process can also allow scanning for known scenarios such as hard coded secrets.


## Getting Started

1. Clone this Repo
2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
3. Decide which [operation](https://github.com/databricks/terraform-databricks-sra/tree/main/aws/tf#operation-mode) mode you'd like to use.
4. Fill out `sra.tf` in place
5. Fill out `example.tfvars` and place in `tf` directory, remove the .example part of the file name
6. CD into `tf`
7. Run `terraform init`
8. Run `terraform validate`
9. From `tf` directory, run `terraform plan -var-file ../example.tfvars`
10. Run `terraform apply -var-file ../example.tfvars`


## Network Diagram - Sandbox
![Architecture Diagram](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/img/Sandbox%20-%20Network%20Topology.png)


## Network Diagram - Firewall
![Architecture Diagram](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/img/Firewall%20-%20Network%20Topology.png)


## Network Diagram - Isolated
![Architecture Diagram](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/img/Isolated%20-%20Network%20Topology.png)


## FAQ

- **I've cloned the GitHub repo, what's the recommended way to add Databricks additional resources to it?**

If you'd like to add additional resources to the repository, the first step is to identify if this resource is using the **account** or **workspace** provider.

For example, if it uses the **account** provider, then we'd recommend creating a new module under the [modules/sra/databricks_account](https://github.com/databricks/terraform-databricks-sra/tree/main/aws/tf/modules/sra/databricks_account) folder. Then, that module can be called in the top level [databricks_account.tf](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/tf/modules/sra/databricks_account.tf) file. This process is the same for the workspace provider by placing a new module in the [modules/sra/databricks_workspace folder](https://github.com/databricks/terraform-databricks-sra/tree/main/aws/tf/modules/sra/databricks_workspace) and call it in the [databricks_workspace.tf](https://github.com/databricks/terraform-databricks-sra/blob/main/aws/tf/modules/sra/databricks_workspace.tf) file.