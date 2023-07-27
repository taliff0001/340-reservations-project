set serveroutput on

set autocommit on

set echo on

set pages 1000 lines 120

prompt "Drop/Load main schema"
/

@A.sql
/
-- Load Data Common To Test Cases

prompt "Drop/Load Control Procedures"
/

@B.sql
/


prompt "Load Test Data"
/

@C.sql



prompt "End ctrl"