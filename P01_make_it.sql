SET SERVEROUTPUT ON;

DROP TABLE Legs;
DROP TABLE Seats;
DROP TABLE Tickets;
DROP TABLE Flights;
DROP TABLE Customers;
DROP TABLE Airports;

DROP SEQUENCE ticket_seq;
DROP SEQUENCE fid_seq;
DROP SEQUENCE cust_seq;

CREATE SEQUENCE cust_seq START WITH 500;
CREATE SEQUENCE fid_seq START WITH 1000;
CREATE SEQUENCE ticket_seq START WITH 4000;

CREATE TABLE Airports (
	airport_code CHAR(3),
	city VARCHAR2(30),
	state CHAR(2),
	CONSTRAINT PK_Airports PRIMARY KEY (airport_code)
);

CREATE TABLE Customers (
	cust_ID NUMBER DEFAULT cust_seq.NEXTVAL,
	first_name VARCHAR2(30) NOT NULL,
	last_name VARCHAR2(30) NOT NULL,
	balance NUMBER(10, 2) DEFAULT 0,
	CONSTRAINT PK_Customers PRIMARY KEY (cust_ID),
    CONSTRAINT negative_bal CHECK(balance >= 0)
);

CREATE TABLE Flights ( 
	FID NUMBER DEFAULT fid_seq.NEXTVAL,
	dep_date DATE,
	dep_airport CHAR(3),
	arrival_date DATE,
	dest_airport CHAR(3),
	CONSTRAINT PK_Flights PRIMARY KEY (FID),
	CONSTRAINT FK_Flights_dep_airport FOREIGN KEY (dep_airport) REFERENCES Airports (airport_code),
	CONSTRAINT FK_Flights_dest_airport FOREIGN KEY (dest_airport) REFERENCES Airports (airport_code),
    CONSTRAINT unique_airport_codes CHECK (dep_airport != dest_airport),
	CONSTRAINT unique_flights UNIQUE (dep_airport, dest_airport)
);

CREATE TABLE Tickets (
	ticket_no NUMBER DEFAULT ticket_seq.NEXTVAL,
	cust_ID NUMBER NOT NULL,
	purchase_date DATE,
	price NUMBER(10,2),
	CONSTRAINT PK_Tickets PRIMARY KEY (ticket_no),
	CONSTRAINT FK_Tickets_cust_ID FOREIGN KEY (cust_ID) REFERENCES Customers (cust_ID)
);

CREATE TABLE Seats (
	seat_no NUMBER(3),
	FID NUMBER,
	row_number NUMBER(3),
	seat CHAR(1),
	seat_loc CHAR(3),
	CONSTRAINT PK_Seats PRIMARY KEY (FID, seat_no),
	CONSTRAINT FK_Seats_FID FOREIGN KEY (FID) REFERENCES Flights (FID)
);

CREATE TABLE Legs (
	FID NUMBER,
	ticket_no NUMBER,
	seat_no NUMBER,
	CONSTRAINT FK_Legs_Flights FOREIGN KEY (FID) REFERENCES Flights (FID),
	CONSTRAINT FK_Legs_Tickets FOREIGN KEY (ticket_no) REFERENCES Tickets (ticket_no),
	CONSTRAINT PK_Legs PRIMARY KEY (FID, ticket_no)
);

SHOW ERRORS;


--------------------------------------------------------------------------------



DROP VIEW Flight_Info_MV;
DROP MATERIALIZED VIEW Airports_MV;  


-----------------------------------------------------------------------------
-- 1. Create a Logical View for sales of baseball products 
-----------------------------------------------------------------------------

CREATE VIEW Flight_Info_LV AS
(  SELECT  day_key, prod_key, Sales_Amount, Units_Sold
   FROM      Sales_Fact 
   WHERE  prod_key IN (1001, 1003, 1004, 1005, 1006, 1008, 1010)
);   


-------------------------------------------------------------------
Airports_MV
-------------------------------------------------------------------

CREATE MATERIALIZED VIEW Airports_MV
 REFRESH ON COMMIT
  AS
  ( 
   SELECT airport_code, city, state
   FROM airports
  );

--------------------------------------------------------------------------------




/* (Needed ceiling function for the add_seats trigger) */

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

/*
Hopefully you'll forgive me - instead of a sequence I wrote this trigger
that auto-loads 60 seats complete with all info for each flight added
*/

CREATE OR REPLACE TRIGGER add_seats_test
 AFTER INSERT ON Flights
 FOR EACH ROW
 DECLARE
  flight_id NUMBER := :NEW.FID;
  next_seat NUMBER(3) := 1;
  next_row INTEGER := 1;
  next_letter CHAR(1) := 'A';
  loc_num NUMBER(1);
  loc CHAR(3) := 'WIN';
 BEGIN
  FOR seat IN 1 .. 60 LOOP
	loc_num := next_seat MOD 6;
	CASE loc_num
	 WHEN 1 THEN loc := 'WIN';
	 WHEN 2 THEN loc := 'MID';
	 WHEN 3 THEN loc := 'AIS';
	 WHEN 4 THEN loc := 'AIS';
	 WHEN 5 THEN loc := 'MID';
	 ELSE loc := 'WIN';
	END CASE;
   INSERT INTO Seats (FID, seat_no, row_number, seat, seat_loc)
   VALUES (flight_id, next_seat, CEILING(next_seat / 6), next_letter, loc);
   next_seat := next_seat + 1;
   next_letter := CHR(ASCII(next_letter) + 1);
   IF next_letter = 'G' THEN next_letter := 'A';
   END IF;
  END LOOP;
END;
/

/* 
This trigger assumes the purchase date is the current SYSDATE
and checks the previous 24 hours for purchases before adding
*/

CREATE OR REPLACE TRIGGER check_purchase_date
 BEFORE INSERT ON TICKETS
 FOR EACH ROW
 DECLARE
  new_id NUMBER := :NEW.cust_ID;
  PURCHASE_LIM EXCEPTION;
 BEGIN
  FOR ticket IN (SELECT purchase_date FROM tickets WHERE cust_ID = new_id) LOOP
    IF ticket.purchase_date > (SYSDATE - INTERVAL '24' HOUR)
	THEN RAISE PURCHASE_LIM;
	END IF;
  END LOOP;

 EXCEPTION
  WHEN PURCHASE_LIM THEN
	DBMS_OUTPUT.PUT_LINE('Customer has exceeded 24-hour purchase limit');
	RAISE_APPLICATION_ERROR(-20001, 'Insert operation aborted.');
END;
/

SHOW ERRORS;