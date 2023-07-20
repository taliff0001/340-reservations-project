set serveroutput on

prompt "Drop/Load main schema"
/

@P05_make_07_20.sql
/

prompt "Drop/Load Control Procedures"
/

@P05_cmd.sql
/


-- Load Data Common To Test Cases

prompt "Load Airports / Customer / Flight"
/

@P05_common.sql