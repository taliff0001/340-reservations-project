-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- CMD / PROCEDURES  -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --




-- USAGE:
--
-- Command Table
-- -------------
-- [cmd_ID] is a key representing the corresponding row in the Sim_Data table
-- [cmd] is a 3-character string representing the desired operation
-- Possible operations are ['add'] ['scd'] ['fnd'] ['res']
--
-- Sim_Data Table
-- --------------
-- Each row represents data to be processed by the corresponding [cmd_ID]/[cmd]
--
--
-- Execute commands on a range of rows by calling the cmd function:
-- ----------------------------------------------------------------
-- [exec cmd(<first row>, <final row>)]
--


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

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / INS');
        RAISE;

    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / INS');
        RAISE;

    WHEN INVALID_NUMBER OR VALUE_ERROR THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / INS');
        RAISE;

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR:  ' || sqlerrm);
        RAISE;

END ins;
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
            -- -- -- -- Schedule Flight -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

CREATE OR REPLACE PROCEDURE scd
(current_row IN SMALLINT)

    IS
    sim_row Sim_Data%ROWTYPE;
BEGIN

    SELECT * INTO sim_row FROM Sim_Data
    WHERE Sim_Data.cmd_ID = current_row;


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

    WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / SCD');
    RAISE;

    WHEN TOO_MANY_ROWS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / SCD');
    RAISE;

    WHEN INVALID_NUMBER OR VALUE_ERROR THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / SCD');
    RAISE;

    WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ERROR / SCD:  ' || sqlerrm);
    RAISE;

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
    WHERE Sim_Data.cmd_ID = current_row;


    seat := reserve.find_open_seat(FL_ID);

    DBMS_OUTPUT.PUT_LINE('FOUND SEAT NO.  ' || seat);



EXCEPTION

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / FND');

    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / FND');

    WHEN INVALID_NUMBER OR VALUE_ERROR THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / FND');

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR / FND:  ' || sqlerrm);

END fnd;
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- Reserve a flight - OLDER / P03 VERSION -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

create or replace procedure old_res
(current_row IN SMALLINT)

    IS

    cust_no customers.cust_id%type;
    Flight_ID flights.fid%type;
    seat_num seats.seat_no%type;
    ticket_price tickets.price%type;
    ticket_num tickets.ticket_no%TYPE;


BEGIN

    SELECT p1 INTO cust_no FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p2 INTO Flight_ID FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p3 INTO seat_num FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT cost INTO ticket_price FROM flights WHERE flights.fid = Flight_ID;

    reserve_flight(cust_no, Flight_ID, seat_num, ticket_price, ticket_num);

    DBMS_OUTPUT.PUT_LINE('ISSUED TICKET_NO:  ' || ticket_num);
    DBMS_OUTPUT.PUT_LINE('PURCHASE PRICE:  ' || ticket_price);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / RES');

    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / RES');

    WHEN INVALID_NUMBER OR VALUE_ERROR THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / RES');

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR / RES:  ' || sqlerrm);

END old_res;
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
    return_val NUMBER;
    ticket_num tickets.ticket_no%type;

BEGIN

    SELECT p1 INTO cust_num FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p2 INTO FID_1 FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p3 INTO FID_2 FROM sim_data WHERE sim_data.cmd_id = current_row;
    SELECT p4 INTO FID_3 FROM sim_data WHERE sim_data.cmd_id = current_row;

    CASE

        WHEN FID_2 IS NULL AND FID_3 IS NULL THEN
            return_val := reserve.reserve_em(FID_1, cust_num, ticket_num);

        WHEN FID_3 IS NULL THEN
            return_val := reserve.reserve_em(FID_1, FID_2, cust_num, ticket_num);

        ELSE
            return_val := reserve.reserve_em(FID_1, FID_2, FID_3, cust_num, ticket_num);

        END CASE;

        DBMS_OUTPUT.PUT_LINE('ISSUED TICKET_NO:  ' || ticket_num);
        DBMS_OUTPUT.PUT_LINE('RES RETURNED:  ' || return_val);
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / RES');

    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / RES');

    WHEN INVALID_NUMBER OR VALUE_ERROR THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / RES');

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR / RES:  ' || sqlerrm);

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
            WHEN CMND = 'old_res' THEN old_res(curr_row);
            END CASE;

        IF curr_row = end_row THEN EXIT;
        ELSE curr_row := curr_row + 1;
        END IF;


    END LOOP;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / CMD');

    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / CMD');

    WHEN INVALID_NUMBER OR VALUE_ERROR THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / CMD');

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR / RES:  ' || sqlerrm);

END CMD;
/

COMMIT;
