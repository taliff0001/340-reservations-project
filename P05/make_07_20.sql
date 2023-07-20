CREATE OR REPLACE PROCEDURE debit_cust_acct
(
    cust_num IN customers.cust_id%type,
    ticket_price IN tickets.price%type
) is
    insufficient_funds EXCEPTION;
    PRAGMA EXCEPTION_INIT (insufficient_funds, -02290);
BEGIN
    UPDATE customers
    SET balance = balance - ticket_price
    WHERE cust_id = cust_num;
EXCEPTION
    WHEN insufficient_funds THEN
        DBMS_OUTPUT.PUT_LINE('INSUFFICIENT FUNDS TO RESERVE FLIGHT');
        RAISE;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR/DEBIT_CUST_ACCT: ' || SQLERRM);
        RAISE;
END debit_cust_acct;
/
--------------------------------------------------------------------
-- BEGIN RESERVATIONS PACKAGE --
--------------------------------------------------------------------

CREATE OR REPLACE PACKAGE reserve AS
    -- Record type for holding seat info
    TYPE seats_holder IS RECORD
     (
         FID SMALLINT,
         Seat_no SMALLINT
     );
    -- Varray type for holding multiple seats
    TYPE mo_seats_holder IS VARRAY(3) OF seats_holder;

    -- Function to find open seat
    FUNCTION find_open_seat(flightID IN NUMBER) RETURN NUMBER;

    FUNCTION find_mo_seats(flightID_1 IN NUMBER) RETURN mo_seats_holder;
    -- Functions for finding multiple open seats --
    FUNCTION find_mo_seats(flightID_1 IN NUMBER, flightID_2 IN NUMBER) RETURN mo_seats_holder;
    FUNCTION find_mo_seats(flightID_1 IN NUMBER, flightID_2 IN NUMBER, flightID_3 IN NUMBER) RETURN mo_seats_holder;

    PROCEDURE res_flight(seats_varray mo_seats_holder, cust_num customers.cust_id%TYPE);

    PROCEDURE debit_cust_acct (cust_num IN customers.cust_id%type, ticket_price IN tickets.price%type);

    FUNCTION get_flights_cost
    (
        FID1 IN flights.FID%TYPE DEFAULT -1,
        FID2 IN flights.FID%TYPE DEFAULT -1,
        FID3 IN flights.FID%TYPE DEFAULT -1
    )
        RETURN flights.cost%TYPE;

END reserve;
/

create or replace PACKAGE BODY reserve AS

    PROCEDURE debit_cust_acct
    (
        cust_num IN customers.cust_id%type,
        ticket_price IN tickets.price%type
    ) is
        insufficient_funds EXCEPTION;
        PRAGMA EXCEPTION_INIT (insufficient_funds, -02290);
    BEGIN
        UPDATE customers
        SET balance = balance - ticket_price
        WHERE cust_id = cust_num;
    EXCEPTION
        WHEN insufficient_funds THEN
            DBMS_OUTPUT.PUT_LINE('INSUFFICIENT FUNDS TO RESERVE FLIGHT');
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR/DEBIT_CUST_ACCT: ' || SQLERRM);
            RAISE;
    END debit_cust_acct;

--------------------------------------------------------------------
    -- SEAT FINDING FUNCTIONS --
--------------------------------------------------------------------

    -- Original function find_open_seat
    FUNCTION find_open_seat(flightID IN NUMBER) RETURN NUMBER IS
        num_rows Number;
        return_seat_no NUMBER;
    BEGIN
        SELECT COUNT(*) INTO num_rows FROM seats
        WHERE FID = flightID;
        IF num_rows > 0 THEN
            SELECT MIN(seat_no) INTO return_seat_no FROM seats
            WHERE FID = flightID;
            RETURN return_seat_no;
        ELSE
            return -1;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR/FIND_OPEN_SEAT ' || SQLERRM);
            RETURN -1;
    END find_open_seat;

    -- find_mo_seats that only takes one flight ID
    FUNCTION find_mo_seats(flightID_1 IN NUMBER) RETURN mo_seats_holder IS
        seats_varray mo_seats_holder := mo_seats_holder();
    BEGIN

        seats_varray.extend;
        seats_varray(1).FID := flightID_1;
        seats_varray(1).Seat_no := find_open_seat(flightID_1);
        RETURN seats_varray;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR/FIND_MO_SEATS ' || SQLERRM);
            RETURN seats_varray;

    END find_mo_seats;

    -- Overloaded find_mo_seats with two flight IDs
    FUNCTION find_mo_seats(flightID_1 IN NUMBER, flightID_2 IN NUMBER) RETURN mo_seats_holder IS
        seats_varray mo_seats_holder := mo_seats_holder();
    BEGIN
        seats_varray.extend;
        seats_varray(1).FID := flightID_1;
        seats_varray(1).Seat_no := find_open_seat(flightID_1);
        seats_varray.extend;
        seats_varray(2).FID := flightID_2;
        seats_varray(2).Seat_no := find_open_seat(flightID_2);
        RETURN seats_varray;
    END find_mo_seats;

    -- Overloaded find_mo_seats with three flight IDs
    FUNCTION find_mo_seats(flightID_1 IN NUMBER, flightID_2 IN NUMBER, flightID_3 IN NUMBER) RETURN mo_seats_holder IS
        seats_varray mo_seats_holder := mo_seats_holder();
    BEGIN
        seats_varray.extend;
        seats_varray(1).FID := flightID_1;
        seats_varray(1).Seat_no := find_open_seat(flightID_1);
        seats_varray.extend;
        seats_varray(2).FID := flightID_2;
        seats_varray(2).Seat_no := find_open_seat(flightID_2);
        seats_varray.extend;
        seats_varray(3).FID := flightID_3;
        seats_varray(3).Seat_no := find_open_seat(flightID_3);
        RETURN seats_varray;
    END find_mo_seats;

--------------------------------------------------------------------
    -- GET FLIGHTS COST --
--------------------------------------------------------------------

    FUNCTION get_flights_cost
    (
        FID1 IN flights.FID%TYPE DEFAULT -1,
        FID2 IN flights.FID%TYPE DEFAULT -1,
        FID3 IN flights.FID%TYPE DEFAULT -1
    )
        RETURN flights.cost%TYPE

        IS

        cost1 flights.cost%TYPE;
        cost2 flights.cost%TYPE;
        cost3 flights.cost%TYPE;
        total_cost flights.cost%TYPE;
        invalid_parameter EXCEPTION;
        PRAGMA EXCEPTION_INIT (invalid_parameter, -02290);

    BEGIN

        CASE
            WHEN FID2 = -1 AND FID3 = -1 THEN
                SELECT cost INTO cost1 FROM flights
                WHERE FID = FID1;
                total_cost := cost1;
            WHEN FID3 = -1 THEN
                SELECT cost INTO cost1 FROM flights
                WHERE FID = FID1;
                SELECT cost INTO cost2 FROM flights
                WHERE FID = FID2;
                total_cost := cost1 + cost2;
            ELSE
                SELECT cost INTO cost1 FROM flights
                WHERE FID = FID1;
                SELECT cost INTO cost2 FROM flights
                WHERE FID = FID2;
                SELECT cost INTO cost3 FROM flights
                WHERE FID = FID3;
                total_cost := cost1 + cost2 + cost3;
            END CASE;

        -- probably unnecessary
        IF total_cost < 0 THEN
            RAISE invalid_parameter;
        END IF;

        DBMS_OUTPUT.PUT_LINE('TOTAL COST: '||total_cost);
        RETURN total_cost;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('PROBLEM GETTING TICKET COST: '||SQLCODE||' '||SQLERRM);
            RETURN -1;
    END;



--------------------------------------------------------------------
    -- RESERVE FLIGHT - ONE TO THREE LEGS --
--------------------------------------------------------------------

    PROCEDURE res_flight(seats_varray mo_seats_holder, cust_num customers.cust_id%TYPE)

        IS

        ticket_price flights.cost%TYPE;
        seat_num seats.seat_no%TYPE;
        wrong_num_seats EXCEPTION;
        PRAGMA EXCEPTION_INIT (wrong_num_seats, -02290);

    BEGIN
        CASE
            WHEN seats_varray.COUNT = 1 THEN
                ticket_price := get_flights_cost(seats_varray(1).FID);
            WHEN seats_varray.COUNT = 2 THEN
                ticket_price := get_flights_cost(seats_varray(1).FID, seats_varray(2).FID);
            WHEN seats_varray.COUNT = 3 THEN
                ticket_price := get_flights_cost(seats_varray(1).FID, seats_varray(2).FID, seats_varray(3).FID);
            ELSE
                RAISE wrong_num_seats;
            END CASE;
        DBMS_OUTPUT.PUT_LINE('Ticket_Price: ' || ticket_price);
        debit_cust_acct(cust_num, ticket_price);

        insert into tickets(ticket_no, cust_id, purchase_date, price)
        values(ticket_seq.nextval, cust_num, sysdate, ticket_price);

        CASE
            WHEN seats_varray.COUNT = 1 THEN

                DELETE FROM seats
                WHERE FID = seats_varray(1).FID
                  AND seat_no = seats_varray(1).seat_no;
                insert into legs(FID, ticket_no,seat_no)
                values(seats_varray(1).FID, ticket_seq.currval,seats_varray(1).seat_no);

            WHEN seats_varray.COUNT = 2 THEN

                DELETE FROM seats
                WHERE FID = seats_varray(1).FID
                  AND seat_no = seats_varray(1).seat_no;
                insert into legs(FID, ticket_no,seat_no)
                values(seats_varray(1).FID, ticket_seq.currval,seats_varray(1).seat_no);

                DELETE FROM seats
                WHERE FID = seats_varray(2).FID
                  AND seat_no = seats_varray(2).seat_no;
                insert into legs(FID, ticket_no,seat_no)
                values(seats_varray(2).FID, ticket_seq.currval,seats_varray(2).seat_no);

            WHEN seats_varray.COUNT = 3 THEN

                DELETE FROM seats
                WHERE FID = seats_varray(1).FID
                  AND seat_no = seats_varray(1).seat_no;
                insert into legs(FID, ticket_no,seat_no)
                values(seats_varray(1).FID, ticket_seq.currval,seats_varray(1).seat_no);

                DELETE FROM seats
                WHERE FID = seats_varray(2).FID
                  AND seat_no = seats_varray(2).seat_no;
                insert into legs(FID, ticket_no,seat_no)
                values(seats_varray(2).FID, ticket_seq.currval,seats_varray(2).seat_no);

                DELETE FROM seats
                WHERE FID = seats_varray(3).FID
                  AND seat_no = seats_varray(3).seat_no;
                insert into legs(FID, ticket_no,seat_no)
                values(seats_varray(3).FID, ticket_seq.currval,seats_varray(3).seat_no);

            ELSE
                RAISE wrong_num_seats;

            END CASE;

        DBMS_OUTPUT.PUT_LINE('FOUND ' || seats_varray.COUNT || ' SEATS');

    EXCEPTION
        WHEN wrong_num_seats THEN
            DBMS_OUTPUT.PUT_LINE('ERROR/WRONG_NUM_SEATS:  ' || SQLERRM);
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR/RESERVE_FLIGHT:  ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            RAISE;
    END;
END reserve;
/

COMMIT;

--------------------------------------------------------------------
-- END RESERVATIONS PACKAGE --
--------------------------------------------------------------------






CREATE OR REPLACE PROCEDURE reserve_em
(
FID1 IN flights.FID%TYPE,
FID2 flights.FID%TYPE,
FID3 flights.FID%TYPE,
cust_num customers.cust_id%TYPE
)
    IS

    seats_varray  reserve.mo_seats_holder;

BEGIN
    seats_varray := reserve.find_mo_seats(FID1, FID2, FID3);
    reserve.res_flight(seats_varray, cust_num);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('RESERVATION SUCCESSFUL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: '||SQLCODE||' '||SQLERRM);
        ROLLBACK;
END;
/

COMMIT;