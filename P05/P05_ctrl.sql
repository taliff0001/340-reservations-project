set serveroutput on

prompt "Drop/Load main schema"
/

@P05_make.sql
/

prompt "Drop/Load Control Procedures"
/

@P05_cmd.sql
/


-- Load Data Common To Test Cases

prompt "Load Airports / Customer / Flight"
/

@P05_common.sql


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


--------------------------------------------------------------------
P05 Test Values
--------------------------------------------------------------------

insert into airports values ('RIC', 'Richmond', 'VA');
insert into airports values ('BWI', 'Baltimore', 'MD');
insert into airports values ('MDT', 'Harrisburg', 'PA');
insert into airports values ('CVG', 'Cincinnatti', 'OH');
insert into airports values ('DFW', 'Dallas', 'TX');
insert into airports values ('SNA', 'Orange County', 'CA');
insert into airports values ('LAX', 'Los Angeles', 'CA');
insert into airports values ('LAS', 'Las Vegas', 'NV');


INSERT INTO Command (cmd_id, cmd) VALUES (7, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (7, 1, '1002', '8930', '8/1/2023', 'RIC', '9/1/2023', 'MDT', '325');

INSERT INTO Command (cmd_id, cmd) VALUES (8, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (8, 1, '1003', '6928', '8/1/2023', 'MDT', '8/1/2023', 'CVG', '250');

COMMIT;




*/