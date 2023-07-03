
/*
All customer balances initialize to 0, I didn't think those values
were relevant at this point. I also left out dates for flights.
*/

SET SERVEROUTPUT ON;

insert into airports values ('RIC', 'Richmond', 'VA');
insert into airports values ('BWI', 'Baltimore', 'MD');
insert into airports values ('MDT', 'Harrisburg', 'PA');
insert into airports values ('CVG', 'Cincinnatti', 'OH');
insert into airports values ('DFW', 'Dallas', 'TX');
insert into airports values ('SNA', 'Orange County', 'CA');
insert into airports values ('LAX', 'Los Angeles', 'CA');

insert into customers (first_name, last_name) values ('Tommy', 'Aliff');
insert into customers (first_name, last_name) values ('Cole', 'Daniels');
insert into customers (first_name, last_name) values ('Burt', 'Reynolds');

INSERT INTO FLIGHTS (dep_airport, dest_airport) VALUES ('RIC', 'BWI');
INSERT INTO FLIGHTS (dep_airport, dest_airport) VALUES ('MDT', 'CVG');
INSERT INTO FLIGHTS (dep_airport, dest_airport) VALUES ('CVG', 'LAX');
INSERT INTO FLIGHTS (dep_airport, dest_airport) VALUES ('DFW', 'SNA');

/* First ticket insert is different than the other so as not to violate the business rule */
INSERT INTO tickets (cust_ID, purchase_date, price) VALUES (500, TO_DATE('13-AUG-22 12:56 P.M.','DD-MON-YY HH:MI A.M.'), 300);
INSERT INTO Legs (FID, ticket_no, seat_no) VALUES (1001, ticket_seq.CURRVAL, 1);
INSERT INTO Legs (FID, ticket_no, seat_no) VALUES (1002, ticket_seq.CURRVAL, 1);

INSERT INTO tickets (cust_ID, purchase_date, price) VALUES (500, SYSDATE, 625);
INSERT INTO Legs (FID, ticket_no, seat_no) VALUES (1000, ticket_seq.CURRVAL, 1);

INSERT INTO tickets (cust_ID, purchase_date, price) VALUES (501, SYSDATE, 1100);
INSERT INTO Legs (FID, ticket_no, seat_no) VALUES (1000, ticket_seq.CURRVAL, 2);

COMMIT;

SHOW ERRORS;



