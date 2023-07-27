DROP VIEW Flight_Info_LV;
DROP MATERIALIZED VIEW Airports_MV;
DROP TABLE Reservations_audit;
DROP TABLE Seats;
DROP TABLE Legs;
DROP TABLE Tickets;
DROP TABLE Flights;
DROP TABLE Customers;
DROP TABLE Airports;

DROP SEQUENCE ticket_seq;
DROP SEQUENCE fid_seq;
DROP SEQUENCE cust_seq;
DROP SEQUENCE audit_seq;

CREATE SEQUENCE cust_seq START WITH 500;
CREATE SEQUENCE fid_seq START WITH 1000;
CREATE SEQUENCE ticket_seq START WITH 4000;
CREATE SEQUENCE audit_seq;

CREATE TABLE Airports
(
    airport_code CHAR(3),
    city         VARCHAR2(30),
    state        CHAR(2),
    CONSTRAINT PK_Airports PRIMARY KEY (airport_code)
);

CREATE TABLE Customers
(
    cust_ID    NUMBER,
    first_name VARCHAR2(30) NOT NULL,
    last_name  VARCHAR2(30) NOT NULL,
    balance    NUMBER(10, 2) DEFAULT 0,
    CONSTRAINT PK_Customers PRIMARY KEY (cust_ID),
    CONSTRAINT negative_bal CHECK (balance >= 0)
);

CREATE TABLE Flights
(
    FID          NUMBER,
    flight_no    CHARACTER(6),
    dep_date     DATE,
    dep_airport  CHAR(3),
    arrival_date DATE,
    dest_airport CHAR(3),
    cost         NUMBER(8, 2),
    CONSTRAINT PK_Flights PRIMARY KEY (FID),
    CONSTRAINT FK_Flights_dep_airport FOREIGN KEY (dep_airport) REFERENCES Airports (airport_code),
    CONSTRAINT FK_Flights_dest_airport FOREIGN KEY (dest_airport) REFERENCES Airports (airport_code),
    CONSTRAINT unique_airport_codes CHECK (dep_airport != dest_airport)
);

CREATE TABLE Seats
(
    seat_no    NUMBER(3),
    FID        NUMBER,
    row_number NUMBER(3),
    seat       CHAR(1),
    seat_loc   CHAR(3),
    CONSTRAINT PK_Seats PRIMARY KEY (seat_no, FID),
    CONSTRAINT FK_Seats_FID FOREIGN KEY (FID) REFERENCES Flights (FID)
);

CREATE TABLE Tickets
(
    ticket_no     NUMBER,
    cust_ID       NUMBER NOT NULL,
    purchase_date DATE,
    price         NUMBER(10, 2),
    purchase_day  AS (TO_CHAR(purchase_date, 'DD-MM-YYYY')),
    CONSTRAINT PK_Tickets PRIMARY KEY (ticket_no),
    CONSTRAINT FK_Tickets_cust_ID FOREIGN KEY (cust_ID) REFERENCES Customers (cust_ID),
    CONSTRAINT unique_customer_purchase UNIQUE (cust_ID, purchase_day)
);

CREATE TABLE Legs
(
    FID       NUMBER,
    ticket_no NUMBER,
    seat_no   NUMBER(3) NOT NULL,
    CONSTRAINT PK_Legs PRIMARY KEY (FID, ticket_no),
    CONSTRAINT FK_Legs_Flights FOREIGN KEY (FID) REFERENCES Flights (FID),
    CONSTRAINT FK_Legs_Ticket_No FOREIGN KEY (ticket_no) REFERENCES Tickets (ticket_no)
);

CREATE TABLE reservations_audit
(
    audit_id       NUMBER,
    username       VARCHAR2(15),
    passenger_id   NUMBER,
    ticket_no      NUMBER,
    time_of_record DATE,
    CONSTRAINT FK_audit_passID FOREIGN KEY (passenger_id) REFERENCES Customers (cust_ID),
    CONSTRAINT FK_audit_ticket_no FOREIGN KEY (ticket_no) REFERENCES Tickets (ticket_no)
);


/*
     TIME FOR SOME VIEWS

           |  |
        ___|  |___
        \        /
         \      /
          \    /
           \  /
            \/
*/

CREATE VIEW Flight_Info_LV AS
(
SELECT 
    F.FID,
    F.dep_airport,
    F.dep_date,
    F.dest_airport,
    F.arrival_date,
    (SELECT COUNT(*) FROM seats WHERE FID = F.FID) - 
    (SELECT COUNT(*) FROM legs WHERE FID = F.FID) AS Open_Seats 
FROM 
    flights F
GROUP BY 
    F.FID, F.dep_airport, F.dep_date, F.dest_airport, F.arrival_date
);

CREATE MATERIALIZED VIEW Airports_MV
    REFRESH ON COMMIT
AS
(
SELECT airport_code, city, state
FROM Airports
    );

/*

    FUNCTIONS DOWN YONDER

           |  |
        ___|  |___
        \        /
         \      /
          \    /
           \  /
            \/



(Wanted a ceiling function for the add_seats trigger)
*/

CREATE OR REPLACE FUNCTION CEILING(x NUMBER)
    RETURN NUMBER AS
    result NUMBER;
BEGIN
    result := FLOOR(x);
    IF result < x THEN
        result := result + 1;
    END IF;

    RETURN result;
END;
/


CREATE OR REPLACE PROCEDURE add_seats(
    flightID IN flights.fid%TYPE,
    num_rows IN INTEGER,
    seats_per IN INTEGER
)
    IS

    seat_let    CHAR(1) := 'A';
    total_seats INTEGER := num_rows * seats_per;
    loc_num     NUMBER(1);
    loc         CHAR(3);

BEGIN

    FOR seat IN 1 .. total_seats
        LOOP

            loc_num := seat MOD 3;

            CASE loc_num
                WHEN 1 THEN loc := 'WIN';
                WHEN 2 THEN loc := 'MID';
                ELSE loc := 'AIS';
                END CASE;

            INSERT INTO Seats (FID, seat_no, row_number, seat, seat_loc)
            VALUES (flightID, seat, CEILING(seat / seats_per), seat_let, loc);

            IF ASCII(seat_let) > (63 + seats_per) THEN
                seat_let := 'A';
            ELSE
                seat_let := CHR(ASCII(seat_let) + 1);
            END IF;

        END LOOP;

    COMMIT;

EXCEPTION

    WHEN OTHERS THEN
        dbms_output.put_line('ERROR/ADD_SEATS:   ' || sqlerrm);

END add_seats;
/

--------------------------------------------------------------------
-- Missing Stored Procedures (Functions) from P03 --
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION add_airport(
    code IN airports.airport_code%TYPE,
    cty IN airports.city%TYPE,
    st IN airports.state%TYPE
) RETURN SMALLINT
    IS
BEGIN
    INSERT INTO airports (airport_code, city, state)
    VALUES (code, cty, st);
    COMMIT;
    RETURN 1;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
        RETURN -1;
    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS');
        RETURN -1;
END add_airport;
/

CREATE OR REPLACE FUNCTION add_customer(
    first IN customers.first_name%TYPE,
    last IN customers.last_name%TYPE,
    bal IN customers.balance%TYPE
) RETURN SMALLINT
    IS
BEGIN
    INSERT INTO customers (cust_id, first_name, last_name, balance)
    VALUES (cust_seq.nextval, first, last, bal);
    COMMIT;
    RETURN 1;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
        RETURN -1;
    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS');
        RETURN -1;
END add_customer;
/

CREATE OR REPLACE PROCEDURE reserve_flight
(
    cust_num IN customers.cust_id%type,
    FlightID IN flights.fid%type,
    seat_num IN legs.seat_no%type,
    ticket_price IN tickets.price%type,
    ticket_num OUT tickets.ticket_no%TYPE
) is

    INSUFFICIENT_FUNDS EXCEPTION;
    PRAGMA EXCEPTION_INIT (insufficient_funds, -02290);

begin

    ticket_num := ticket_seq.nextval;

    insert into tickets(ticket_no, cust_id, purchase_date, price)
    values(ticket_num, cust_num, sysdate, ticket_price);

    insert into legs(FID, ticket_no,seat_no)
    values(FlightID, ticket_num,seat_num);

    debit_cust_acct(cust_num, ticket_price);

    commit;


EXCEPTION

    WHEN INSUFFICIENT_FUNDS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('INSUFFICIENT FUNDS TO RESERVE FLIGHT');
        RAISE;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
        RAISE;

    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS');
        RAISE;

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;
/





--------------------------------------------------------------------
-- RESERVATIONS PKG --
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE debit_cust_acct(
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
        DBMS_OUTPUT.PUT_LINE('ERROR/DEBIT_CUST_ACCT: ' || SQLERRM || DBMS_UTILITY.FORMAT_CALL_STACK());
        RAISE;
END debit_cust_acct;
/
--------------------------------------------------------------------
-- BEGIN PACKAGE DEF / RESERVE --
--------------------------------------------------------------------

CREATE OR REPLACE PACKAGE reserve AS
    -- Record type for holding seat info
    TYPE seats_holder IS RECORD
                         (
                             FID     SMALLINT,
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

    PROCEDURE res_flight(seats_varray mo_seats_holder, cust_num customers.cust_id%TYPE, ticket_num OUT tickets.ticket_no%TYPE);

    PROCEDURE debit_cust_acct(cust_num IN customers.cust_id%type, ticket_price IN tickets.price%type);

    FUNCTION get_flights_cost(
        FID1 IN flights.FID%TYPE DEFAULT -1,
        FID2 IN flights.FID%TYPE DEFAULT -1,
        FID3 IN flights.FID%TYPE DEFAULT -1
    )
        RETURN flights.cost%TYPE;

    FUNCTION reserve_em(
        FID1 IN flights.FID%TYPE,
        FID2 IN flights.FID%TYPE,
        FID3 IN flights.FID%TYPE,
        cust_num IN customers.cust_id%TYPE,
        ticket_num OUT tickets.ticket_no%TYPE
    ) RETURN NUMBER;

    FUNCTION reserve_em(
        FID1 IN flights.FID%TYPE,
        FID2 IN flights.FID%TYPE,
        cust_num IN customers.cust_id%TYPE,
        ticket_num OUT tickets.ticket_no%TYPE
    ) RETURN NUMBER;

    FUNCTION reserve_em(
        FID1 IN flights.FID%TYPE,
        cust_num IN customers.cust_id%TYPE,
        ticket_num OUT tickets.ticket_no%TYPE
    ) RETURN NUMBER;


END reserve;
/

--------------------------------------------------------------------
-- BEGIN PACKAGE BODY / RESERVE --
--------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY reserve AS

    PROCEDURE debit_cust_acct(
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

        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            RAISE;

        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS');
            RAISE;

        WHEN OTHERS THEN RAISE;

    END debit_cust_acct;

--------------------------------------------------------------------
    -- SEAT FINDING FUNCTIONS --
--------------------------------------------------------------------

-- Original function find_open_seat
    FUNCTION find_open_seat(flightID IN NUMBER) RETURN NUMBER IS
        return_seat_no NUMBER;

    BEGIN
        select MIN(seat_no)
        INTO return_seat_no
        FROM (select seat_no
              from seats
              where fid = flightID
              MINUS
              select seat_no
              from legs
              where fid = flightID);

        IF return_seat_no IS NULL THEN
            RETURN -1;
        END IF;

        RETURN return_seat_no;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / FIND_OPEN_SEAT');
            RAISE;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / FIND_OPEN_SEAT');
            RAISE;
        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / FIND_OPEN_SEAT');
            RAISE;

        WHEN OTHERS THEN RAISE;

    END find_open_seat;

-- Find_mo_seats that takes a single FID --

    FUNCTION find_mo_seats(flightID_1 IN NUMBER) RETURN mo_seats_holder IS
        seats_varray mo_seats_holder := mo_seats_holder();

    BEGIN

        seats_varray.extend;
        seats_varray(1).FID := flightID_1;
        seats_varray(1).Seat_no := find_open_seat(flightID_1);
        RETURN seats_varray;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / FIND_MO_SEATS');
            RAISE;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / FIND_OPEN_SEAT / FIND_MO_SEATS');
            RAISE;
        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / FIND_OPEN_SEAT / FIND_MO_SEATS');
            RAISE;

        WHEN OTHERS THEN RAISE;

    END find_mo_seats;

-- Overloaded find_mo_seats with two flight IDs --

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

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / FIND_MO_SEATS');
            RAISE;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / FIND_OPEN_SEAT / FIND_MO_SEATS');
            RAISE;
        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / FIND_OPEN_SEAT / FIND_MO_SEATS');
            RAISE;

        WHEN OTHERS THEN RAISE;

    END find_mo_seats;

    -- Overloaded find_mo_seats with three flight IDs --

    FUNCTION find_mo_seats(flightID_1 IN NUMBER, flightID_2 IN NUMBER, flightID_3 IN NUMBER) RETURN mo_seats_holder
        IS
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

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / FIND_MO_SEATS');
            RAISE;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / FIND_OPEN_SEAT / FIND_MO_SEATS');
            RAISE;
        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / FIND_OPEN_SEAT / FIND_MO_SEATS');
            RAISE;

        WHEN OTHERS THEN RAISE;

    END find_mo_seats;

--------------------------------------------------------------------
    -- GET FLIGHTS COST --
--------------------------------------------------------------------

    FUNCTION get_flights_cost(
        FID1 IN flights.FID%TYPE DEFAULT -1,
        FID2 IN flights.FID%TYPE DEFAULT -1,
        FID3 IN flights.FID%TYPE DEFAULT -1
    )
        RETURN flights.cost%TYPE
        IS

        cost1      flights.cost%TYPE;
        cost2      flights.cost%TYPE;
        cost3      flights.cost%TYPE;
        total_cost flights.cost%TYPE;
        invalid_parameter EXCEPTION;
        PRAGMA EXCEPTION_INIT (invalid_parameter, -02290);

    BEGIN

        CASE

            WHEN FID2 = -1 AND FID3 = -1 THEN SELECT cost
                                              INTO cost1
                                              FROM flights
                                              WHERE FID = FID1;
                                              total_cost := cost1;

            WHEN FID3 = -1 THEN SELECT cost
                                INTO cost1
                                FROM flights
                                WHERE FID = FID1;
                                SELECT cost
                                INTO cost2
                                FROM flights
                                WHERE FID = FID2;
                                total_cost := cost1 + cost2;

            ELSE SELECT cost
                 INTO cost1
                 FROM flights
                 WHERE FID = FID1;
                 SELECT cost
                 INTO cost2
                 FROM flights
                 WHERE FID = FID2;
                 SELECT cost
                 INTO cost3
                 FROM flights
                 WHERE FID = FID3;
                 total_cost := cost1 + cost2 + cost3;

            END CASE;

        -- probably unnecessary
        IF total_cost < 0 THEN
            RAISE invalid_parameter;
        END IF;

        DBMS_OUTPUT.PUT_LINE('TOTAL COST: ' || total_cost);

        RETURN total_cost;

    EXCEPTION

        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('PROBLEM GETTING TICKET COST: ' || SQLCODE || ' ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_CALL_STACK()); RETURN -1;
    END;

--------------------------------------------------------------------
    -- RESERVE FLIGHT - ONE TO THREE LEGS --
--------------------------------------------------------------------

    PROCEDURE res_flight
        (
        seats_varray IN mo_seats_holder,
        cust_num IN customers.cust_id%TYPE,
        ticket_num OUT tickets.ticket_no%TYPE
        )
        IS
        ticket_price flights.cost%TYPE;

    BEGIN

        ticket_num := ticket_seq.nextval;
        insert into tickets(ticket_no, cust_id, purchase_date)
        values (ticket_num, cust_num, sysdate);

        CASE

            WHEN seats_varray.COUNT = 1 THEN -- ONE LEG

                ticket_price := get_flights_cost (seats_varray(1).FID);

                INSERT INTO legs(FID, ticket_no, seat_no)
                VALUES (seats_varray(1).FID, ticket_num, seats_varray(1).seat_no);

            WHEN seats_varray.COUNT = 2 THEN -- TWO LEGS

                ticket_price := get_flights_cost (seats_varray(1).FID, seats_varray(2).FID);

                INSERT INTO legs(FID, ticket_no, seat_no)
                VALUES (seats_varray(1).FID, ticket_num, seats_varray(1).seat_no);

                INSERT INTO legs(FID, ticket_no, seat_no)
                VALUES (seats_varray(2).FID, ticket_num, seats_varray(2).seat_no);

            ELSE -- THREE LEGS

                ticket_price := get_flights_cost(seats_varray(1).FID,
                                             seats_varray(2).FID, seats_varray(3).FID);

                INSERT INTO legs(FID, ticket_no, seat_no)
                VALUES (seats_varray(1).FID, ticket_num, seats_varray(1).seat_no);

                INSERT INTO legs(FID, ticket_no, seat_no)
                VALUES (seats_varray(2).FID, ticket_num, seats_varray(2).seat_no);

                INSERT INTO legs(FID, ticket_no, seat_no)
                VALUES (seats_varray(3).FID, ticket_num, seats_varray(3).seat_no);

            END CASE;

        UPDATE tickets SET price = ticket_price WHERE tickets.ticket_no = ticket_num;

        debit_cust_acct(cust_num, ticket_price);

        DBMS_OUTPUT.PUT_LINE('FOUND ' || seats_varray.COUNT || ' SEATS');

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND / RES_FLIGHT');
            RAISE;

        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS / RES_FLIGHT');
            RAISE;

        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / RES_FLIGHT');
            RAISE;

        WHEN OTHERS THEN RAISE;

    END res_flight;

--------------------------------------------------------------------
    -- RESERVE THEM JANKS --
--------------------------------------------------------------------

    FUNCTION reserve_em(
        FID1 IN flights.FID%TYPE,
        FID2 IN flights.FID%TYPE,
        FID3 IN flights.FID%TYPE,
        cust_num IN customers.cust_id%TYPE,
        ticket_num OUT tickets.ticket_no%TYPE
    ) RETURN NUMBER

        IS

        seats_varray reserve.mo_seats_holder;

    BEGIN

        CASE

            WHEN FID2 = -1 AND FID3 = -1 THEN seats_varray := find_mo_seats(FID1);
            WHEN FID3 = -1 THEN seats_varray := find_mo_seats(FID1, FID2);
            ELSE seats_varray := find_mo_seats(FID1, FID2, FID3);

            END CASE;

        res_flight(seats_varray, cust_num, ticket_num);

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('RESERVATION SUCCESSFUL');

        RETURN 1;

    EXCEPTION

        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('BAD INPUT PARAMETERS / RES_FLIGHT');
            DBMS_OUTPUT.PUT_LINE('ERROR/RESERVE_EM: ' || DBMS_UTILITY.FORMAT_CALL_STACK());
            RETURN -1;

        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('ERROR/RESERVE_EM: ' || SQLCODE || ' ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('ERROR/RESERVE_EM: ' || DBMS_UTILITY.FORMAT_CALL_STACK());
            RETURN -1;

    END reserve_em;

-- Overloaded -- Two Flights --

    FUNCTION reserve_em(
        FID1 IN flights.FID%TYPE,
        FID2 IN flights.FID%TYPE,
        cust_num IN customers.cust_id%TYPE,
        ticket_num OUT tickets.ticket_no%TYPE
    ) RETURN NUMBER

        IS

        return_val NUMBER;

    BEGIN
        return_val := reserve_em(FID1, FID2, -1, cust_num, ticket_num);
        RETURN return_val;

    EXCEPTION

        WHEN OTHERS THEN RAISE;

    END;

-- Overloaded -- One Flight --

    FUNCTION reserve_em(
        FID1 IN flights.FID%TYPE,
        cust_num IN customers.cust_id%TYPE,
        ticket_num OUT tickets.ticket_no%TYPE
    ) RETURN NUMBER

        IS

        return_val NUMBER;

    BEGIN

        return_val := reserve_em(FID1, -1, -1, cust_num, ticket_num);

        RETURN return_val;

    EXCEPTION

        WHEN OTHERS THEN RAISE;

    END;

END reserve;
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- END RESERVATIONS PKG --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- AUDIT TRIGGER --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

create or replace trigger reservation_audit_trig
    after insert
    on tickets
    for each row

begin

    insert into reservations_audit(audit_id, username, passenger_id, ticket_no, time_of_record)
    values (audit_seq.nextval, 'FLT_RES', :new.cust_id, :new.ticket_no, sysdate);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('AUDIT TRIGGER ERROR: ' || SQLERRM);

END Reservation_Audit_Trig;
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- FLIGHT SCHEDULING --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

CREATE OR REPLACE PROCEDURE schedule_flight_all_params(
    Fl_ID IN Flights.FID%TYPE,
    Fl_No IN Flights.Flight_No%TYPE,
    d_date IN Flights.Dep_Date%TYPE,
    d_airport IN Flights.Dep_Airport%TYPE,
    a_date IN Flights.Arrival_Date%TYPE,
    a_airport IN Flights.Dest_Airport%TYPE,
    rows IN Seats.Row_Number%TYPE,
    seats_per IN Seats.Seat_No%TYPE,
    price IN Flights.cost%TYPE
)
    IS

BEGIN

    INSERT INTO Flights (FID, flight_no,
                         dep_date, dep_airport, arrival_date, dest_airport, cost)

    VALUES (FL_ID, FL_No, d_date, d_airport, a_date, a_airport, price);

    add_seats(FL_ID, rows, seats_per);

    COMMIT;

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR/SCHEDULE_FLIGHT:  ' || sqlerrm);
        ROLLBACK;

END Schedule_Flight_all_params;
/

-- Overloaded for auto-generation of FID / Flight Number

CREATE OR REPLACE PROCEDURE schedule_flight(
    d_date IN Flights.Dep_Date%TYPE,
    d_airport IN Flights.Dep_Airport%TYPE,
    a_date IN Flights.Arrival_Date%TYPE,
    a_airport IN Flights.Dest_Airport%TYPE,
    rows IN Seats.Row_Number%TYPE,
    seats_per IN Seats.Seat_No%TYPE,
    price IN Flights.cost%TYPE
)
    IS

    random_flight_no VARCHAR2(6) :=
        round(dbms_random.value(100000, 999999));

BEGIN

    schedule_flight_all_params
        (
            fid_seq.NEXTVAL, random_flight_no, d_date,
            d_airport, a_date, a_airport, rows, seats_per, price
        );
    COMMIT;

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR/SCHEDULE_FLIGHT:  ' || sqlerrm);
        ROLLBACK;
END;
/

COMMIT;