-- ============================================================================
-- Oracle CDC prerequisites for Databricks Lakeflow Connect (Amazon RDS Oracle).
--
-- SQL reference for running directly in a client (SQL Developer, sqlplus) with
-- access to the DB. The notebooks in this folder do the same over TLS from
-- serverless. Run as the RDS MASTER user (e.g. oracleadmin).
--
-- FLOW:
--   1. This script  — enable ARCHIVELOG retention + supplemental logging.
--   2. dbx-oracle-setup-package.sql — Databricks' official package: creates a
--      DEDICATED replication user and grants it the LogMiner privileges. The
--      connector's validator REQUIRES a dedicated user (it rejects the RDS
--      master user even when that user holds every privilege).
--   3. Point the UC connection at that dedicated user.
-- ============================================================================

-- 1) Archive-log retention. ARCHIVELOG mode itself is ON when automated backups
--    are enabled (backup_retention_period > 0). Databricks recommends ~48h.
exec rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours', 48);

-- 2) Database-level supplemental logging (required for CDC). PRIMARY KEY is the
--    documented minimum; use 'ALL' if PK/unique columns can change.
exec rdsadmin.rdsadmin_util.alter_supplemental_logging(p_action => 'ADD');
exec rdsadmin.rdsadmin_util.alter_supplemental_logging(p_action => 'ADD', p_type => 'PRIMARY KEY');

-- 3) Verify
-- SELECT log_mode FROM v$database;                                        -- expect ARCHIVELOG
-- SELECT supplemental_log_data_min, supplemental_log_data_pk FROM v$database;  -- expect YES / YES

-- 4) Now run dbx-oracle-setup-package.sql, then:
--      exec dbx_oracle_setup_util.create_user('DBX_CDC', '<password>', 'USERS', 'TEMP');
--      exec dbx_oracle_setup_util.grant_permissions('DBX_CDC');
--      exec dbx_oracle_setup_util.grant_select_permissions('DBX_CDC', '<SOURCE_SCHEMA>');
--      exec dbx_oracle_setup_util.validate_setup('DBX_CDC');
--
-- NOTE on source tables: Oracle LogMiner SKIPS any table that has an IDENTITY
-- column. Model CDC source tables with a plain NUMBER primary key instead.
