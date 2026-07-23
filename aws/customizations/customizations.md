# Customizations

Customizations are **Terraform code** available to support the baseline deployment of the **Security Reference Architecture (SRA) - Terraform Templates**.

Customizations are sectioned by providers:
- **Workspace**: Databricks workspace provider.
- **AWS**: AWS provider (customer-side infrastructure).

The current customizations available are:

| Provider                    | Customization                 | Summary |
|-----------------------------|-------------------------------|---------|
| **Workspace** | **Workspace Admin Configurations** | Workspace administration configurations can be enabled to align with security best practices. The Terraform resource is experimental and optional, with documentation on each configuration provided in the Terraform file. |
| **Workspace** | **Security Analysis Tool (SAT)** | The Security Analysis Tool evaluates a customer’s Databricks account and workspace security configurations, providing recommendations that align with Databricks’ best practices. This can be enabled within the workspace. |
| **Workspace** | **Audit Log Alerting** | Based on this [blog post](https://www.databricks.com/blog/improve-lakehouse-security-monitoring-using-system-tables-databricks-unity-catalog), Audit Log Alerting creates 40+ SQL alerts to monitor incidents following a Zero Trust Architecture (ZTA) model. **NOTE:** This configuration creates a cluster, a job, and queries within your environment. |
| **Workspace** | **Read-Only External Location** | Creates a read-only external location in Unity Catalog for a specified bucket, as well as the corresponding AWS IAM role. |
| **AWS** | **Serverless PrivateLink to Git** | Implements the customer-side setup in [serverless private Git](https://docs.databricks.com/aws/en/repos/serverless-private-git): an internal NLB fronting a self-hosted Git server (HTTPS/SSH) and a VPC endpoint service allowlisting the Databricks serverless private-connectivity role. Region-aware across commercial and GovCloud (civilian/DoD). |
| **AWS** | **Serverless PrivateLink to Kafka** | Implements steps 1–2 of [private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network): an internal NLB fronting an internal Apache Kafka cluster and a VPC endpoint service allowlisting the Databricks serverless private-connectivity role. Region-aware across commercial and GovCloud (civilian/DoD). |
| **AWS** | **Serverless PrivateLink to RDS** | Implements steps 1–2 of [private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network): an internal NLB fronting an Amazon RDS instance and a VPC endpoint service allowlisting the Databricks serverless private-connectivity role. Region-aware across commercial and GovCloud (civilian/DoD). |
| **AWS** | **Serverless PrivateLink to S3 (interface)** | Implements steps 1–2 of [private connectivity from serverless compute to your internal network](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-to-internal-network): an S3 interface endpoint fronted by an internal NLB and a VPC endpoint service. For most S3 access the native NCC `resource_names` path is simpler; use this only when S3 must traverse your own endpoint service. Region-aware across commercial and GovCloud (civilian/DoD). |