set serveroutput on

set echo on

set pages 50000 lines 120

prompt "Drop/Load main schema"
/

@P05a.sql
/
-- Load Data Common To Test Cases

prompt "Drop/Load Control Procedures"
/

@P05b.sql
/


prompt "Load Test Data"
/

@P05c.sql



prompt "End ctrl"