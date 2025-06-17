# Customizations

Customizations are **Terraform code** available to support the baseline deployment of the **Security Reference Architecture (SRA) - Terraform Templates**.

Customizations are sectioned by providers:
- **Workspace**: Databricks workspace provider.

The current customizations available are:

| Provider                    | Customization                 | Summary |
|-----------------------------|-------------------------------|---------|
| **Account** | **Audit and Billable Usage Logs** | Databricks delivers logs to your S3 buckets. [Audit logs](https://docs.databricks.com/administration-guide/account-settings/audit-logs.html) contain workspace and account-level events. Additionally, [Billable usage logs](https://docs.databricks.com/administration-guide/account-settings/billable-usage-delivery.html) are delivered daily to an AWS S3 bucket, containing historical data about cluster usage in DBUs for each workspace. |
| **Workspace** | **Workspace Admin Configurations** | Workspace administration configurations can be enabled to align with security best practices. The Terraform resource is experimental and optional, with documentation on each configuration provided in the Terraform file. |
| **Workspace** | **IP Access Lists** | IP Access can be enabled to restrict console access to a subset of IPs. **NOTE:** Ensure IPs are accurate to prevent lockout scenarios. |
| **Workspace** | **Security Analysis Tool (SAT)** | The Security Analysis Tool evaluates a customer’s Databricks account and workspace security configurations, providing recommendations that align with Databricks’ best practices. This can be enabled within the workspace. |
| **Workspace** | **Audit Log Alerting** | Based on this [blog post](https://www.databricks.com/blog/improve-lakehouse-security-monitoring-using-system-tables-databricks-unity-catalog), Audit Log Alerting creates 40+ SQL alerts to monitor incidents following a Zero Trust Architecture (ZTA) model. **NOTE:** This configuration creates a cluster, a job, and queries within your environment. |
| **Workspace** | **Read-Only External Location** | Creates a read-only external location in Unity Catalog for a specified bucket, as well as the corresponding AWS IAM role. |