-- =============================================================================
-- Oracle CDC Setup Script
-- =============================================================================
-- Copyright: 2025, Databricks Inc. All rights reserved.
--
-- Description:
--   This script prepares an Oracle Database for CDC using LogMiner.
--
-- PREREQUISITES:
--   - Running this script requires SYSDBA privileges.
--   - Supplemental logging and ARCHIVELOG mode MUST be enabled before running this script.
-- ============================================================================

create or replace package dbx_oracle_setup_util authid current_user as
    procedure create_user(
        user_name       varchar2,
        password        varchar2,
        tablespace      varchar2,
        temp_tablespace varchar2
    );
    procedure grant_permissions(
        user_name               varchar2
    );
    procedure drop_user(user_name varchar2);
    procedure grant_select_permissions(
        user_name   varchar2,
        schema_name varchar2,
        pdb_name    varchar2 default null
    );
    procedure grant_select_on_table(
        user_name   varchar2,
        schema_name varchar2,
        table_name  varchar2,
        pdb_name    varchar2 default null
    );
    procedure validate_setup(
        username               varchar2
    );
end dbx_oracle_setup_util;
/

create or replace package body dbx_oracle_setup_util as
    -- These variables are scoped to the package body and current session only.
    -- Oracle retains these values for the duration of the session and then clears them.
    -- We use this state in this script to avoid some repetitive checks.
    g_is_cdb      boolean;
    g_is_rds      boolean;
    g_is_rac      boolean;
    g_initialized boolean := false;

    -- Application error codes (raise_application_error range: -20000 .. -20999).
    -- Keep these unique so a raised error unambiguously identifies its cause.
    err_cdb_on_rds            constant pls_integer := -20001;
    err_not_cdb_root          constant pls_integer := -20002;
    err_no_archivelog         constant pls_integer := -20003;
    err_insufficient_dba      constant pls_integer := -20004;
    err_username_not_upper    constant pls_integer := -20005;
    err_pdb_name_required     constant pls_integer := -20006;
    err_common_user_required  constant pls_integer := -20007;
    err_user_not_found        constant pls_integer := -20008;
    err_missing_privileges    constant pls_integer := -20009;
    err_rac_not_supported     constant pls_integer := -20010;

    type grant_type is record(
        obj_name  varchar2(100),
        privilege varchar2(10)
    );

    type grant_type_array is varray(50) of grant_type;

    -- System privileges and roles granted unconditionally to the CDC user.
    -- privilege is null: obj_name is a system privilege (or role) granted by name.
    system_privileges constant grant_type_array := grant_type_array(
        grant_type(obj_name => 'CREATE SESSION', privilege => null),
        grant_type(obj_name => 'SELECT ANY TRANSACTION', privilege => null),
        grant_type(obj_name => 'LOGMINING', privilege => null),
        grant_type(obj_name => 'SELECT ANY DICTIONARY', privilege => null)
    );

    -- Object privileges: SELECT/EXECUTE on LogMiner packages, SYS tables, and V$/GV$ views.
    -- On RDS these are granted via rdsadmin.rdsadmin_util.grant_sys_object; elsewhere via
    -- a standard GRANT (see grant_permissions).
    object_privileges constant grant_type_array := grant_type_array(
        -- packages and tables
        grant_type(obj_name => 'DBMS_LOGMNR', privilege => 'EXECUTE'),
        grant_type(obj_name => 'DBMS_LOGMNR_D', privilege => 'EXECUTE'),
        grant_type(obj_name => 'DBA_SEGMENTS', privilege => 'SELECT'),
        -- V$ and GV$ views
        grant_type(obj_name => 'V_$TRANSACTION', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$DATABASE', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$CONTAINERS', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$PDBS', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$SESSION', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$INSTANCE', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$LOGFILE', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$LOG', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$ARCHIVED_LOG', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$LOGMNR_CONTENTS', privilege => 'SELECT'),
        grant_type(obj_name => 'V_$PARAMETER', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$TRANSACTION', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$DATABASE', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$CONTAINERS', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$PDBS', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$SESSION', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$INSTANCE', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$LOGFILE', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$LOG', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$ARCHIVED_LOG', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$LOGMNR_CONTENTS', privilege => 'SELECT'),
        grant_type(obj_name => 'GV_$PARAMETER', privilege => 'SELECT')
    );

    -- System privileges granted only in CDB environments (CONTAINER=ALL via grant_permission).
    cdb_only_privileges constant grant_type_array := grant_type_array(
        grant_type(obj_name => 'SET CONTAINER', privilege => null)
    );

    -- RDS specific validations
    rds_object_privileges constant grant_type_array := grant_type_array(
        grant_type(obj_name => 'RDSADMIN.RDS_CONFIGURATION', privilege => 'SELECT')
    );

    -- If the db is a container database
    function is_cdb return integer is
        v_cdb varchar2(3);
    begin
        select cdb into v_cdb from v$database;
        if v_cdb = 'YES' then
            return 1;
        else
            return 0;
        end if;
    end;

    -- If current session is CDB$ROOT
    function is_cdb_root return integer is
        v_container varchar2(100);
    begin
        select sys_context('USERENV', 'CON_NAME') into v_container from dual;
        if v_container = 'CDB$ROOT' then
            return 1;
        else
            return 0;
        end if;
    end;

    -- If this is an RDS installation
    function is_rds return integer is
        v_count number;
    begin
        select count(*) into v_count from all_objects 
        where object_name = 'RDSADMIN' and object_type = 'PACKAGE';
        if v_count > 0 then
            return 1;
        else
            return 0;
        end if;
    end;

    -- If this is an RAC installation
    function is_rac return integer is
        v_database_type varchar2(20);
    begin
        select database_type into v_database_type from gv$instance;
        if v_database_type = 'RAC' or v_database_type = 'RACONENODE' then
            return 1;
        else
            return 0;
        end if;
    end;

    -- Check if current user has DBA privileges required for CDC setup
    procedure validate_dba_privileges is
        v_has_dba_role    number := 0;
        v_has_create_user number := 0;
    begin
        -- Check if user has DBA role
        begin
            select count(*) into v_has_dba_role from dba_role_privs
            where grantee = user and granted_role = 'DBA';
        exception
            when others then
                v_has_dba_role := 0;
        end;

        -- Check if user has CREATE USER privilege
        begin
            select count(*) into v_has_create_user from dba_sys_privs
            where grantee = user and privilege = 'CREATE USER';
        exception
            when others then
                v_has_create_user := 0;
        end;

        -- Validate that user has sufficient privileges (DBA role OR CREATE USER privilege)
        if v_has_dba_role = 0 and v_has_create_user = 0 then
            raise_application_error(err_insufficient_dba,
                'Insufficient privileges: This package requires DBA role or CREATE USER privilege. '
                || 'Current user (' || user || ') lacks the necessary permissions for CDC setup.');
        end if;
    end;

    -- Private initialization procedure
    procedure initialize is
    begin
        if not g_initialized then
            -- Validate DBA privileges first
            validate_dba_privileges;
            g_is_rds := (is_rds() = 1);
            g_is_cdb := (is_cdb() = 1);
            g_is_rac := (is_rac() = 1);
            g_initialized := true;
        end if;
    end;

    procedure validate_environment as
    begin
        if g_is_cdb and g_is_rds then
            raise_application_error(err_cdb_on_rds,
                'Script terminated: Container databases are not supported on RDS.');
        end if;
        if g_is_cdb and is_cdb_root() = 0 then
            raise_application_error(err_not_cdb_root,
                'Script terminated: This script must be executed in the CDB$ROOT container for a CDB environment.');
        end if;
        if g_is_rac then
            raise_application_error(err_rac_not_supported,
                'Script terminated: RAC is not supported.');
        end if;
    end;

    -- Warns (does not fail) when no database-level supplemental logging mode is enabled,
    -- since the user may instead enable table-level supplemental logging per table.
    procedure validate_supplemental_logging_enabled as
        supp_logging_min varchar2(10);
        supp_logging_all varchar2(10);
        supp_logging_pk  varchar2(10);
        supp_logging_ui  varchar2(10);
    begin
        select supplemental_log_data_min, supplemental_log_data_all, 
               supplemental_log_data_pk, supplemental_log_data_ui
        into supp_logging_min, supp_logging_all, supp_logging_pk, supp_logging_ui
        from gv$database;

        if supp_logging_min = 'NO' and supp_logging_all = 'NO' and 
           supp_logging_pk = 'NO' and supp_logging_ui = 'NO' then
            dbms_output.put_line('Supplemental logging is not enabled at database level.');
            dbms_output.put_line('WARN: Make sure that at least minimal supplemental logging is enabled at table level for all tables to be replicated.');
            dbms_output.put_line('Please follow the steps in documentation to enable supplemental logging.');
            -- Not throwing error because table level supplemental logging might be enabled
            -- To check table level logging, we need to know the table names and check against dba_log_groups
        end if;
    end;

    procedure validate_archive_log_enabled as
        log_mode varchar2(30);
    begin
        select log_mode into log_mode from gv$database;
        if log_mode = 'NOARCHIVELOG' then
            dbms_output.put_line('ARCHIVELOG mode is not enabled.');
            dbms_output.put_line('Please follow the steps in documentation to enable ARCHIVELOG mode.');
            raise_application_error(err_no_archivelog,
                'ARCHIVELOG mode not enabled. Please enable it and re-run this script.');
        end if;
    end;

    procedure validate_uppercase_user_name(user_name varchar2) is
    begin
        if user_name != upper(user_name) then
            raise_application_error(err_username_not_upper,
                'Invalid user_name: This script expects an all-caps username. '
                || 'Provided user_name (' || user_name || ') is not uppercase.');
        end if;
    end;

    procedure enter_pdb_for_select_grants(
        user_name           varchar2,
        pdb_name            varchar2,
        require_common_user boolean
    ) is
    begin
        if not g_is_cdb then
            return;
        end if;
        if pdb_name is null then
            raise_application_error(err_pdb_name_required,
                'pdb_name is required in a CDB environment.');
        end if;
        if require_common_user and upper(substr(user_name, 1, 3)) != 'C##' then
            raise_application_error(err_common_user_required,
                'In a CDB environment, user_name must be a common user (C## prefix required). '
                || 'Provided: ' || user_name);
        end if;
        execute immediate 'ALTER SESSION SET CONTAINER = ' || pdb_name;
    end;

    procedure return_to_cdb_root is
    begin
        if g_is_cdb then
            execute immediate 'ALTER SESSION SET CONTAINER = CDB$ROOT';
        end if;
    end;

    procedure grant_select_to_user(
        user_name   varchar2,
        object_name varchar2
    ) is
    begin
        execute immediate 'GRANT SELECT ON ' || object_name || ' TO ' || upper(user_name);
        dbms_output.put_line('Granted SELECT on ' || object_name || '.');
    end;

    procedure create_user(
        user_name       varchar2,
        password        varchar2,
        tablespace      varchar2,
        temp_tablespace varchar2
    ) is
        v_count integer;
    begin
        initialize;
        validate_uppercase_user_name(user_name);
        select count(*) into v_count from dba_users where USERNAME = upper(user_name);
        if v_count = 0 then
            execute immediate 'CREATE USER ' || user_name || ' IDENTIFIED BY "' || password 
                           || '" DEFAULT TABLESPACE ' || tablespace 
                           || ' TEMPORARY TABLESPACE ' || temp_tablespace
                           || ' QUOTA UNLIMITED ON ' || tablespace;
            dbms_output.put_line('User ' || user_name || ' created successfully.');
        else
            dbms_output.put_line('User ' || user_name || ' already exists. Skipping user creation.');
        end if;
    end;

    procedure grant_permission(
        perm      grant_type,
        user_name varchar2
    ) is
        container_clause varchar2(30);
        sql_stmt         varchar2(4000);
    begin
        if g_is_cdb then
            container_clause := ' CONTAINER=ALL';
        else
            container_clause := '';
        end if;
        
        if perm.privilege is not null then
            sql_stmt := 'GRANT ' || perm.privilege || ' ON ' || perm.obj_name 
                     || ' TO ' || upper(user_name) || container_clause;
        else
            sql_stmt := 'GRANT ' || perm.obj_name || ' TO ' || upper(user_name) || container_clause;
        end if;

        dbms_output.put_line('Executing: ' || sql_stmt);
        execute immediate sql_stmt;
    end;

    -- Grants an object privilege through the RDS-managed rdsadmin package, used on RDS
    -- where direct GRANT on SYS-owned objects is not permitted.
    procedure grant_permission_rds(
        privilege varchar2,
        obj_name  varchar2,
        user_name varchar2
    ) is
        sql_stmt varchar2(4000);
    begin
        sql_stmt := 'begin rdsadmin.rdsadmin_util.grant_sys_object(p_grantee => ''' 
                 || upper(user_name) || ''', p_privilege => ''' || privilege 
                 || ''', p_obj_name => ''' || obj_name || '''); end;';
        dbms_output.put_line('Executing RDS grant: ' || sql_stmt);
        execute immediate sql_stmt;
    end;

    procedure grant_permissions(
        user_name               varchar2
    ) is
    begin
        initialize;
        validate_uppercase_user_name(user_name);

        -- Grant system privileges (always use standard grants)
        dbms_output.put_line('Granting system privileges and roles...');
        for i in 1..system_privileges.count loop
            grant_permission(system_privileges(i), user_name);
        end loop;

        -- Grant object privileges (RDS uses the rdsadmin package, otherwise a standard GRANT)
        dbms_output.put_line('Granting object privileges...');
        for i in 1..object_privileges.count loop
            if g_is_rds then
                grant_permission_rds(object_privileges(i).privilege, object_privileges(i).obj_name, user_name);
            else
                grant_permission(object_privileges(i), user_name);
            end if;
        end loop;

        -- Grant CDB-only privileges (CONTAINER=ALL appended via grant_permission)
        if g_is_cdb then
            dbms_output.put_line('Granting CDB-only privileges...');
            for i in 1..cdb_only_privileges.count loop
                grant_permission(cdb_only_privileges(i), user_name);
            end loop;
        end if;

        -- Grant RDS specific privileges (RDSADMIN-owned objects such as RDS_CONFIGURATION are
        -- granted with a direct GRANT; rdsadmin.rdsadmin_util.grant_sys_object only supports
        -- SYS-owned objects and rejects RDSADMIN.RDS_CONFIGURATION with ORA-20900).
        if g_is_rds then
           dbms_output.put_line('Granting RDS specific privileges...');
           for i in 1..rds_object_privileges.count loop
                grant_permission(rds_object_privileges(i), user_name);
           end loop;
        end if;

        -- Set CONTAINER_DATA for CDB environments
        if g_is_cdb then
            dbms_output.put_line('Setting CONTAINER_DATA=ALL for CDB environment...');
            declare
                sql_stmt varchar2(4000);
            begin
                sql_stmt := 'ALTER USER ' || upper(user_name) || ' SET CONTAINER_DATA=ALL CONTAINER=CURRENT';
                dbms_output.put_line('Executing: ' || sql_stmt);
                execute immediate sql_stmt;
            end;
            dbms_output.put_line('CONTAINER_DATA set successfully.');
        end if;
    end;

    procedure drop_user(user_name varchar2) is
        v_count integer;
    begin
        initialize;
        select count(*) into v_count from dba_users where username = upper(user_name);
        if v_count > 0 then
            execute immediate 'DROP USER ' || user_name || ' CASCADE';
            dbms_output.put_line('User ' || user_name || ' dropped successfully.');
        else
            dbms_output.put_line('User ' || user_name || ' does not exist. Skipping drop user.');
        end if;
    end;

    procedure grant_select_permissions(
        user_name   varchar2,
        schema_name varchar2,
        pdb_name    varchar2 default null
    ) is
        cursor c_tables is
            select table_name from dba_tables
            where owner = upper(schema_name);
    begin
        initialize;
        validate_uppercase_user_name(user_name);
        enter_pdb_for_select_grants(user_name, pdb_name, true);
        begin
            dbms_output.put_line('Granting SELECT permissions on all tables in schema ' || upper(schema_name) || '.');
            for t in c_tables loop
                grant_select_to_user(user_name, upper(schema_name) || '.' || t.table_name);
            end loop;
            dbms_output.put_line('Schema grants complete for ' || upper(schema_name) || '.');
        exception
            when others then
                begin
                    return_to_cdb_root;
                exception
                    when others then null;
                end;
                raise;
        end;
        return_to_cdb_root;
    end;

    procedure grant_select_on_table(
        user_name   varchar2,
        schema_name varchar2,
        table_name  varchar2,
        pdb_name    varchar2 default null
    ) is
    begin
        initialize;
        validate_uppercase_user_name(user_name);
        enter_pdb_for_select_grants(user_name, pdb_name, false);
        grant_select_to_user(user_name, upper(schema_name) || '.' || table_name);
        return_to_cdb_root;
    exception
        when others then
            begin
                return_to_cdb_root;
            exception
                when others then null;
            end;
            raise;
    end;

    procedure validate_database_prerequisites as
    begin
        initialize();
        validate_environment();
        validate_archive_log_enabled();
        validate_supplemental_logging_enabled();
        dbms_output.put_line('Pre-requisite checks passed.');
    end;

    procedure validate_user_exists(user_name varchar2) is
        v_count integer;
    begin
        select count(*) into v_count from dba_users where username = upper(user_name);
        if v_count = 0 then
            raise_application_error(err_user_not_found,
                'User ' || upper(user_name) || ' does not exist. Run create_user first.');
        end if;
        dbms_output.put_line('User ' || upper(user_name) || ' exists.');
    end;

    -- Validates that user_name holds every privilege selected by grant_permissions.
    -- Any missing privilege fails validation.
    procedure validate_user_has_sufficient_privileges(
        user_name               varchar2
    ) is
        v_user       varchar2(128) := upper(user_name);
        v_count      integer;
        v_missing    varchar2(4000) := '';
        v_missing_ct integer := 0;

        procedure record_missing(missing_desc varchar2) is
        begin
            v_missing := v_missing
                || case when v_missing_ct > 0 then ', ' else '' end
                || missing_desc;
            v_missing_ct := v_missing_ct + 1;
        end;
    begin
        -- System privileges and roles: each entry may be held as a system
        -- privilege (dba_sys_privs) or as a role (dba_role_privs).
        for i in 1..system_privileges.count loop
            select count(*) into v_count from (
                select privilege as name from dba_sys_privs where grantee = v_user
                union all
                select granted_role as name from dba_role_privs where grantee = v_user
            ) where name = system_privileges(i).obj_name;
            if v_count = 0 then
                record_missing(system_privileges(i).obj_name);
            end if;
        end loop;

        -- Object privileges: SELECT/EXECUTE on SYS views and LogMiner packages.
        for i in 1..object_privileges.count loop
            select count(*) into v_count from dba_tab_privs
            where grantee = v_user
              and table_name = object_privileges(i).obj_name
              and privilege = object_privileges(i).privilege;
            if v_count = 0 then
                record_missing(object_privileges(i).privilege || ' ON ' || object_privileges(i).obj_name);
            end if;
        end loop;

        -- CDB-only system privileges (e.g. SET CONTAINER).
        if g_is_cdb then
            for i in 1..cdb_only_privileges.count loop
                select count(*) into v_count from (
                    select privilege as name from dba_sys_privs where grantee = v_user
                    union all
                    select granted_role as name from dba_role_privs where grantee = v_user
                ) where name = cdb_only_privileges(i).obj_name;
                if v_count = 0 then
                    record_missing(cdb_only_privileges(i).obj_name);
                end if;
            end loop;
        end if;

        if v_missing_ct > 0 then
            raise_application_error(err_missing_privileges,
                'User ' || v_user || ' is missing ' || v_missing_ct
                || ' required privilege(s): ' || v_missing
                || '. Re-run grant_permissions for this user.');
        end if;

        dbms_output.put_line('Privilege validation passed for user ' || v_user || '.');
    end;

    procedure validate_setup(
        username               varchar2
    ) is
    begin
        initialize();
        validate_database_prerequisites();
        validate_user_exists(username);
        validate_user_has_sufficient_privileges(username);
    end;

end dbx_oracle_setup_util;
/
