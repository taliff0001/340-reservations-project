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

CREATE TABLE Airports (
airport_code CHAR(3),
city VARCHAR2(30),
state CHAR(2)
);

CREATE TABLE Customers (
cust_ID NUMBER,
first_name VARCHAR2(30) NOT NULL,
last_name VARCHAR2(30) NOT NULL,
balance NUMBER(10, 2) DEFAULT 0
);

CREATE TABLE Flights (
FID NUMBER,
flight_no CHARACTER(6),
dep_date DATE,
dep_airport CHAR(3),
arrival_date DATE,
dest_airport CHAR(3),
cost NUMBER(8,2)
);

CREATE TABLE Seats (
seat_no NUMBER(3),
FID NUMBER,
row_number NUMBER(3),
seat CHAR(1),
seat_loc CHAR(3)
);


CREATE TABLE Tickets (
    ticket_no NUMBER,
    cust_ID NUMBER NOT NULL,
    purchase_date DATE,
    price NUMBER(10,2),
    purchase_day AS (TO_CHAR(purchase_date, 'DD-MM-YYYY'))
);

CREATE TABLE Legs (
FID NUMBER,
ticket_no NUMBER,
seat_no NUMBER(3) NOT NULL
);

CREATE TABLE reservations_audit
(
audit_id NUMBER,
username VARCHAR2(15),
passenger_id NUMBER,
flight_num CHAR(6),
departure_time DATE,
time_of_record DATE
);



-- -- -- CONSTRAINTS -- -- --

ALTER TABLE Airports
ADD CONSTRAINT PK_Airports PRIMARY KEY (airport_code);

ALTER TABLE Customers
ADD CONSTRAINT PK_Customers PRIMARY KEY (cust_ID);

ALTER TABLE Customers
ADD CONSTRAINT negative_bal CHECK(balance >= 0);

ALTER TABLE Flights
ADD CONSTRAINT PK_Flights PRIMARY KEY (FID);

ALTER TABLE Flights
ADD CONSTRAINT FK_Flights_dep_airport FOREIGN KEY (dep_airport) REFERENCES Airports (airport_code);

ALTER TABLE Flights
ADD CONSTRAINT FK_Flights_dest_airport FOREIGN KEY (dest_airport) REFERENCES Airports (airport_code);

ALTER TABLE Flights
ADD CONSTRAINT unique_airport_codes CHECK (dep_airport != dest_airport);

ALTER TABLE Tickets
ADD CONSTRAINT PK_Tickets PRIMARY KEY (ticket_no);

ALTER TABLE Tickets
ADD CONSTRAINT FK_Tickets_cust_ID FOREIGN KEY (cust_ID) REFERENCES Customers (cust_ID);

ALTER TABLE Tickets
ADD CONSTRAINT unique_customer_purchase UNIQUE (cust_ID, purchase_day);

ALTER TABLE Legs
ADD CONSTRAINT FK_Legs_Flights FOREIGN KEY (FID) REFERENCES Flights (FID);

ALTER TABLE Legs
ADD CONSTRAINT PK_Legs PRIMARY KEY (FID, ticket_no);

ALTER TABLE Legs
ADD CONSTRAINT UQ_Legs_seat_no UNIQUE (FID, ticket_no, seat_no);

ALTER TABLE Seats
ADD CONSTRAINT PK_Seats PRIMARY KEY (seat_no, FID);

ALTER TABLE Seats
ADD CONSTRAINT FK_Seats_FID FOREIGN KEY (FID) REFERENCES Flights (FID);

ALTER TABLE reservations_audit
ADD CONSTRAINT FK_audit_passID FOREIGN KEY (passenger_id) REFERENCES Customers (cust_id);

ALTER TABLE reservations_audit
ADD CONSTRAINT PK_reservations_audit PRIMARY KEY (audit_id);


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
 SELECT F.FID, F.dep_airport,F.dep_date, F.dest_airport, F.arrival_date,
 MAX(S.seat_no) - MAX(L.seat_no) AS Open_Seats
 FROM Flights F
 JOIN seats S ON F.FID = S.FID
 JOIN legs L ON F.FID = L.FID
 GROUP BY F.FID, F.dep_airport,F.dep_date, F.dest_airport, F.arrival_date
);   



CREATE MATERIALIZED VIEW Airports_MV
 REFRESH ON COMMIT
  AS
  ( 
   SELECT airport_code, city, state
   FROM Airports
  );
  
  COMMIT;


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
 RETURN NUMBER AS result NUMBER;
BEGIN
 result := FLOOR(x);
 IF result < x THEN
    result := result + 1;
 END IF;
  
 RETURN result;
END;
/


CREATE OR REPLACE PROCEDURE add_seats
(
    flightID IN flights.fid%TYPE,
    num_rows IN INTEGER,
    seats_per IN INTEGER
)
  IS

   seat_let CHAR(1) := 'A';
   total_seats INTEGER := num_rows * seats_per;
   loc_num NUMBER(1);
   loc CHAR(3);
  
    BEGIN
    
     FOR seat IN 1 .. total_seats LOOP
     
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


create or replace function find_open_seat
(flightID IN NUMBER) RETURN NUMBER

    IS

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
     
END find_open_seat;
/


create or replace procedure reserve_flight
(
cust_num IN customers.cust_id%type,
FlightID IN flights.fid%type,
seat_num IN legs.seat_no%type,
ticket_price IN tickets.price%type
) is
    insufficient_funds EXCEPTION;
    PRAGMA EXCEPTION_INIT (insufficient_funds, -02290);

    seat_taken_ex EXCEPTION;
    PRAGMA EXCEPTION_INIT (seat_taken_ex, -999999);
    seat_taken BOOLEAN := TRUE;
      
    BEGIN

        UPDATE customers
        SET balance = balance - ticket_price
        WHERE cust_id = cust_num;
        
        FOR seat IN (select seat_no from seats
            where FID = FlightID) LOOP
                IF seat.seat_no = seat_num THEN
                    seat_taken := FALSE;
                END IF;
        END LOOP;
        
        IF seat_taken = TRUE THEN RAISE seat_taken_ex; END IF;
        
        insert into legs(FID, ticket_no,seat_no)
        values(FlightID, ticket_seq.nextval,seat_num);

        DELETE FROM seats
        WHERE seat_no = seat_num;

        insert into tickets(ticket_no, cust_id, purchase_date, price)
        values(ticket_seq.currval, cust_num, sysdate, ticket_price);

        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Reservation completed successfully');


    EXCEPTION
    
        WHEN insufficient_funds THEN
            DBMS_OUTPUT.PUT_LINE('INSUFFICIENT FUNDS TO RESERVE FLIGHT');
            ROLLBACK;
                
        WHEN seat_taken_ex THEN
            DBMS_OUTPUT.PUT_LINE('SEAT TAKEN CHOOSE ANOTHER');
            ROLLBACK;
            
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR/RESERVE_FLIGHT: ' || SQLERRM);
            ROLLBACK;
            
    END reserve_flight;
    /


create or replace procedure fst -- test procedure for find_open_seat
(flightID IN flights.FID%type)
    IS
    seat_var NUMBER(3);
begin
    seat_var := find_open_seat(flightID);
    DBMS_output.put_line('FUNCTION RETURNED:  ' || seat_var);
END;
/


create or replace trigger reservation_audit_trig
after insert on tickets
for each row
    declare
        flightnum flights.flight_no%type;
        invalid_month EXCEPTION;
        PRAGMA EXCEPTION_INIT(invalid_month, -1843);
  begin
        select flight_no into flightnum
        from flights where flights.fid = (select fid from legs where ticket_no = :new.ticket_no);
        insert into reservations_audit(audit_id, username, passenger_id, flight_num, departure_time, time_of_record)
        values(audit_seq.nextval, 'FLT_RES', :new.cust_id, flightnum, :new.purchase_date, sysdate);
    EXCEPTION
        WHEN invalid_month THEN
            DBMS_OUTPUT.PUT_LINE('AUDIT TRIGGER ERROR/INVALID MONTH');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('AUDIT TRIGGER ERROR: ' || SQLERRM);
    
    END Reservation_Audit_Trig;
    /
    
    
    
    
    
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
                -- FLIGHT SCHEDULING --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


     CREATE OR REPLACE PROCEDURE schedule_flight_all_params
     (
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
      


     CREATE OR REPLACE PROCEDURE schedule_flight
     (
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
      round(dbms_random.value(100000,999999));

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