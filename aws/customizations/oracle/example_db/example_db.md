# Example Oracle database

> **For testing only.** The [oracle customization](../oracle.md) assumes you already have the Oracle database you want to connect to. Use this folder only to stand up a throwaway source and sample data for exercising it end to end.

| Folder | Purpose |
|--------|---------|
| [`rds_setup`](rds_setup/rds_setup.md) | Standalone Terraform root that creates an Amazon RDS for Oracle instance with a TCPS (TLS) listener and ARCHIVELOG mode enabled. Its outputs feed the oracle customization's variables. |
| [`test_data_setup`](test_data_setup/create_sample_table_notebook.py) | `create_sample_table_notebook.py` creates a demo schema and sample table with a plain `NUMBER` primary key (LogMiner skips tables with IDENTITY columns) and grants the CDC user read access. |

End-to-end test flow:

1. Apply [`rds_setup`](rds_setup/rds_setup.md) and note its outputs.
2. Run the [`cdc_setup`](../oracle.md#cdc-ingestion-lakeflow-connect) notebooks as the master user to enable CDC prerequisites and create the dedicated CDC user.
3. Run `test_data_setup/create_sample_table_notebook.py` to create the sample source table.
4. Apply the [oracle customization](../oracle.md) with the `rds_setup` outputs and the CDC user, then create the Lakeflow Connect ingestion pipeline.
