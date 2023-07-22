-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- CMD / PROCEDURES  -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

/*

USAGE:

Command Table
-------------
[cmd_ID] is a key representing the corresponding row in the Sim_Data table
[cmd] is a 3-character string representing the desired operation
Possible operations are ['add'] ['scd'] ['fnd'] ['res']

Sim_Data Table
--------------
Each row represents data to be processed by the corresponding [cmd_ID]/[cmd]


Execute commands on a range of rows by calling the cmd function:
----------------------------------------------------------------
[exec cmd(<first row>, <final row>)]

*/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- Insert for Flight or Customer -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

CREATE OR REPLACE PROCEDURE ins
(current_row IN SMALLINT)

    IS

    sim_row Sim_Data%ROWTYPE;

BEGIN

    SELECT * INTO sim_row FROM Sim_Data
    WHERE Sim_Data.cmd_ID = current_row;

    CASE

        WHEN sim_row.p1 = 'airport' THEN
            INSERT INTO Airports (airport_code, city, state)
            VALUES (sim_row.p2, sim_row.p3, sim_row.p4);

        WHEN sim_row.p1 = 'customer' THEN
            INSERT INTO Customers (cust_id, first_name, last_name, balance)
            VALUES (sim_row.p2, sim_row.p3, sim_row.p4, sim_row.p5);

        END CASE;

    COMMIT;

EXCEPTION

    WHEN OTHERS THEN
        dbms_output.put_line('INSERTION ERROR:   ' || sqlerrm);
        ROLLBACK;

END ins;
/

SHOW ERRORS;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
            -- -- -- -- Schedule Flight -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

CREATE OR REPLACE PROCEDURE scd
(current_row IN SMALLINT)

    IS
    sim_row Sim_Data%ROWTYPE;
BEGIN

    SELECT * INTO sim_row FROM Sim_Data
    WHERE Sim_Data.cmd_ID = current_row; -- Should get the row in Command it appears in and execute based on that

    Schedule_Flight_all_params
        (
            sim_row.p1,
            sim_row.p2,
            TO_DATE(sim_row.p3, 'MM/DD/YYYY'),
            sim_row.p4,
            TO_DATE(sim_row.p5, 'MM/DD/YYYY'),
            sim_row.p6,
            20,
            6,
            sim_row.p7
        );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('FLIGHT ADDED');

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SCHEDULING ERROR:  ' || sqlerrm);
        ROLLBACK;

END scd;
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- Find an Open Seat -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

CREATE OR REPLACE PROCEDURE fnd
(current_row IN SMALLINT)
    IS

    FL_ID Flights.FID%TYPE;
    seat Seats.Seat_no%TYPE;

BEGIN

    SELECT p1 INTO FL_ID FROM Sim_data
    WHERE Sim_Data.cmd_ID = current_row;  -- Should get the row in Command it appears in and execute based on that

    seat := find_open_seat(FL_ID);

    DBMS_OUTPUT.PUT_LINE('FOUND SEAT NO.  ' || seat);



EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR FINDING SEAT: ' || SQLERRM);

END fnd;
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- Reserve a flight -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

create or replace procedure res
(current_row IN SMALLINT)

    IS

    cust_num customers.cust_id%type;
    FID_1 flights.fid%type;
    FID_2 flights.fid%type;
    FID_3 flights.fid%type;
    null_parameter EXCEPTION;
    PRAGMA EXCEPTION_INIT(null_parameter, -20999);

BEGIN

    SELECT p1 INTO cust_num FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p2 INTO FID_1 FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p3 INTO FID_2 FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p4 INTO FID_3 FROM sim_data WHERE sim_data.cmd_id = current_row;

    CASE

        WHEN (FID_1 IS NULL AND FID_2 IS NULL AND FID_3 IS NULL)
            OR cust_num IS NULL THEN RAISE null_parameter;

        WHEN FID_2 IS NULL AND FID_3 IS NULL THEN
            reserve.reserve_em(FID_1, cust_num );

        WHEN FID_3 IS NULL THEN
            reserve.reserve_em(FID_1, FID_2, cust_num);

        ELSE
            reserve.reserve_em(FID_1, FID_2, FID_3, cust_num);

        END CASE;

EXCEPTION

    WHEN null_parameter THEN
        DBMS_OUTPUT.PUT_LINE('NULL PARAMETER PASSED TO RES');
        ROLLBACK;

    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / RES CMD');
        ROLLBACK;

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR/RES CMD: ' || SQLERRM);

END res;
/


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- Control For Sim Commands -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


CREATE OR REPLACE PROCEDURE cmd
(start_row IN SMALLINT, end_row IN SMALLINT)

    IS

    CMND Command.cmd%TYPE;
    curr_row SMALLINT := start_row;

BEGIN

    LOOP

        SELECT cmd INTO CMND FROM Command
        WHERE Command.cmd_ID = curr_row;

        CASE
            WHEN CMND = 'add' THEN ins(curr_row);
            WHEN CMND = 'scd' THEN scd(curr_row);
            WHEN CMND = 'fnd' THEN fnd(curr_row);
            WHEN CMND = 'res' THEN res(curr_row);
            END CASE;

        IF curr_row = end_row THEN EXIT;
        ELSE curr_row := curr_row +1;
        END IF;

    END LOOP;

EXCEPTION

    WHEN OTHERS THEN
        dbms_output.put_line('ERROR:   ' || sqlerrm);
END CMD;
/

COMMIT;

SHOW ERRORS;