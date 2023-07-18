set serveroutput on

prompt "Drop/Load main schema"
/

@P04_make.sql
/

prompt "Drop/Load Control Procedures"
/

@P04_cmd.sql
/


-- Load Data Common To Test Cases

prompt "Load Airports / Customer / Flight"
/

@P04_common.sql


/*
--------------------------------------------------------------------
LOAD AND EXECUTE TEST CASE 1 - SUCCESSFUL RESERVATION
--------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (6, 'res');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (6, 1, '100', '1001', '1');

COMMIT;

exec cmd(1,6); <-- Rows to execute

select * from reservations_audit; <-- Display audit results

--------------------------------------------------------------------
                LOAD AND EXECUTE TEST CASE 2:
Search for an already booked seat and attempt to reserve a taken seat
--------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (6, 'res');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (6, 1, '100', '1001', '1'); 

INSERT INTO Command (cmd_id, cmd) VALUES (7, 'fnd');

INSERT INTO Sim_Data (cmd_id, item_no, p1)
VALUES (7, 1, '1001');

INSERT INTO Command (cmd_id, cmd) VALUES (8, 'add');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (8, 1, 'customer', '101', 'Jesus H.', 'Christ', '1000');

INSERT INTO Command (cmd_id, cmd) VALUES (9, 'res');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (9, 1, '101', '1001', '1'); 

COMMIT;

exec cmd(1,9); <-- Rows to execute


select * from reservations_audit; <-- Display audit results

--------------------------------------------------------------------
            LOAD AND EXECUTE TEST CASE 3:
ATTEMP TO PURCHASE A TICKET WITH INSUFFICIENT FUNDS
--------------------------------------------------------------------

UPDATE sim_data SET p5 = 75 WHERE cmd_id = 3;

INSERT INTO Command (cmd_id, cmd) VALUES (6, 'res');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (6, 1, '100', '1001', '1');

COMMIT;

exec cmd(1,6); <-- Rows to execute

select * from reservations_audit; <-- Display audit results

*/