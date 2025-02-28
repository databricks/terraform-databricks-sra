# Security Reference Architecture Template

# Getting Started

1. Clone this Repo
2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
3. CD into `tf`
4. Using `template.tfvars.example` as starting point, supply your variables and place in `tf` directory
5. Run `terraform init`
6. Run `terraform validate`
7. From `tf` directory, run `terraform plan -var-file <YOUR_VAR_FILE>`, if edited directly, the command would be `terraform plan -var-file template.tfvars.example`
8. Run `terraform apply -var-file <YOUR_VAR_FILE`

# Introduction

Databricks has worked with thousands of customers to securely deploy the Databricks platform with appropriate security features to meet their architecture requirements.

This Security Reference Architecture (SRA) repository implements common security features as a unified terraform templates that are typically deployed by our security conscious customers.

# Component Breakdown and Description

In this section, we break down each of the components that we've included in this Security Reference Architecture.

In various .tf scripts, we have included direct links to the Databricks Terraform documentation. The [official documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs) can be found here.

## Infrastructure Deployment

- **Vnet Injection**: [Vnet injection](https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/vnet-inject)
allows Databricks customers to exercise more control over your network configures to comply with specific cloud security and governance standards that a
customer's organization may require.

- **Private Endpoints**: Using Private Link technology, a [private endpoint](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) is a service that connects a customer's Vnet
to Azure services without traversing public IP addresses.

- **Private Link Connectivity**: Private Link provides a private network route from one Azure service to another.
[Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) is configured
so that communication between the customer's data plane and Databricks control plane does not traverse public IP addresses. Both front-end and back-end Private Link are set up in this template according
to the [Simplified Private Link](https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/private-link-simplified) setup.

- **Unity Catalog**:  [Unity Catalog](https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog) is a unified governance solution for all data and AI assets including
files, tables, and machine learning models. Unity Catalog provides a modern approach to granular access controls with centralized policy, auditing, and lineage tracking,
all integrated into your Databricks workflow.

## Post Workspace Deployment

- **Admin Console Configurations**: There are a number of configurations within the [admin console](https://docs.databricks.com/administration-guide/admin-console.html) that
can be controlled to reduce your threat vector. The AWS directory contains examples of configuring these, should your organization desire them.

- **Cluster Tags and Pool Tags**: [Cluster and pool tags](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/account-settings/usage-detail-tags) allow customers to
monitor cost and accurately attribute Databricks usage to your organization's business unit and teams (for chargebacks, for examples). These tags propagate to detailed
DBU usage reports for cost analysis.

# Additional Security Recommendations and Opportunities

In this section, we break down additional security recommendations and opportunities to maintain a strong security posture that either cannot be configured into this
Terraform script or is very specific to individual customers (e.g. SCIM, SSO, etc.)

- **Segment Workspaces for Various Levels of Data Separation**: While Databricks has numerous capabilities for isolating different workloads, such as table ACLs and
IAM passthrough for very sensitive workloads, the primary isolation method is to move sensitive workloads to a different workspace. This sometimes happens when
a customer has very different teams (for example, a security team and a marketing team) who must both analyze different data in Databricks.

- **Avoid Storing Production Datasets in Databricks File Store**: Because the DBFS root is accessible to all users in a workspace, all users can access any data stored here.
It is important to instruct users to avoid using this location for storing sensitive data. The default location for managed tables in the Hive metastore on Databricks is the DBFS root;
to prevent end users who create managed tables from writing to the DBFS root, declare a location on external storage when creating databases in the Hive metastore.

- **Single Sign-On, Multi-factor Authentication, SCIM Provisioning**: Most production or enterprise deployments enable their workspaces to use
[Single Sign-On (SSO)](https://learn.microsoft.com/en-us/azure/databricks/security/auth-authz/#sso) and multi-factor authentication (MFA).
As users are added, changed, and deleted, we recommended customers integrate [SCIM (System for Cross-domain Identity Management)](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/users-groups/scim)
to their account console to sync these actions.

- **Backup Assets from the Databricks Control Plane**: While Databricks does not offer disaster recovery services, many customers use Databricks capabilities, including the Account API,
to create a cold (standby) workspace in another region. This can be done using various tools such as the Databricks [migration tool](https://github.com/databrickslabs/migrate),
[Databricks sync](https://github.com/databrickslabs/databricks-sync), or the [Terraform exporter](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/experimental-exporter)

- **Regularly Restart Databricks Clusters**: When you restart a cluster, it gets the latest images for the compute resource containers and the VM hosts. It is particularly important
to schedule regular restarts for long-running clusters such as those used for processing streaming data. If you enable the compliance security profile for your account or your workspace,
long-running clusters are automatically restarted after 25 days. Databricks recommends that admins restart clusters manually during a scheduled maintenance window.
This reduces the risk of an auto-restart disrupting a scheduled job.

- **Evaluate Whether your Workflow requires using Git Repos or CI/CD**: Mature organizations often build production workloads by using CI/CD to integrate code scanning,
better control permissions, perform linting, and more. When there is highly sensitive data analyzed, a CI/CD process can also allow scanning for known scenarios such as hard coded secrets.

# Network Diagram

![Architecture Diagram](https://cms.databricks.com/sites/default/files/inline-images/db-9734-blog-img-4.png)
