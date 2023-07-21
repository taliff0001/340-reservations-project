set serveroutput on

prompt "Drop/Load main schema"
/

@P05_make_07_20.sql
/
-- Load Data Common To Test Cases

prompt "Load Test Data"
/

@P05_common.sql

prompt "Drop/Load Control Procedures"
/

@P05_cmd.sql
/

