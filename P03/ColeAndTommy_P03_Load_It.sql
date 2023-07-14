SET SERVEROUTPUT ON;

-- Airports -----------------------------------------------------------

insert into airports values ('RIC', 'Richmond', 'VA');
insert into airports values ('BWI', 'Baltimore', 'MD');
insert into airports values ('MDT', 'Harrisburg', 'PA');
insert into airports values ('CVG', 'Cincinnatti', 'OH');
insert into airports values ('DFW', 'Dallas', 'TX');
insert into airports values ('SNA', 'Orange County', 'CA');
insert into airports values ('LAX', 'Los Angeles', 'CA');

-- Added 7/5 --

insert into airports values ('DTW', 'Detroit', 'MI');
insert into airports values ('ATL', 'Atlanta', 'GA');
insert into airports values ('LAS', 'Las Vegas', 'NV');

INSERT INTO Customers (cust_ID, first_name, last_name, balance) 
VALUES (cust_seq.NEXTVAL, 'Cole', 'Daniels', 150.00);

INSERT INTO Customers (cust_ID, first_name, last_name, balance)
VALUES (cust_seq.NEXTVAL, 'Tommy', 'Aliff', 250.00);

insert into customers (cust_ID, first_name, last_name)
values (cust_seq.NEXTVAL, 'Burt', 'Reynolds');

insert into customers (cust_ID, first_name, last_name)
values (cust_seq.NEXTVAL, 'Salvador', 'Dali');

insert into customers (cust_ID, first_name, last_name)
values (cust_seq.NEXTVAL, 'The Michelin', 'Man');

insert into customers (cust_ID, first_name, last_name)
values (cust_seq.NEXTVAL, 'Your Worst', 'Nightmare');

insert into customers (cust_ID, first_name, last_name)
values (cust_seq.NEXTVAL, 'Cancer', 'Scare');


-- FLIGHTS --------------------------------------------------------------


INSERT INTO Flights (FID, flight_no, dep_date, dep_airport, arrival_date, dest_airport)
VALUES (fid_seq.NEXTVAL, 'ABC001', TO_DATE('2023-08-03 05:48:00', 'YYYY-MM-DD HH24:MI:SS'), 'RIC', TO_DATE('2023-08-03 07:29:00', 'YYYY-MM-DD HH24:MI:SS'), 'DTW');
exec add_seats(fid_seq.currval, 10, 6);

INSERT INTO Flights (FID, flight_no, dep_date, dep_airport, arrival_date, dest_airport)
VALUES (fid_seq.NEXTVAL, 'DEF002', TO_DATE('2023-08-10 05:20:00', 'YYYY-MM-DD HH24:MI:SS'), 'DTW', TO_DATE('2023-08-10 07:16:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL');
exec add_seats(fid_seq.currval, 10, 6);

INSERT INTO Flights (FID, flight_no, dep_date, dep_airport, arrival_date, dest_airport)
VALUES (fid_seq.NEXTVAL, 'GHI003', TO_DATE('2023-08-10 08:04:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL', TO_DATE('2023-08-10 09:40:00', 'YYYY-MM-DD HH24:MI:SS'), 'RIC');
exec add_seats(fid_seq.currval, 10, 6);

INSERT INTO Flights (FID, flight_no, dep_date, dep_airport, arrival_date, dest_airport)
VALUES (fid_seq.NEXTVAL, 'JKL004', TO_DATE('2023-08-04 07:16:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL', TO_DATE('2023-08-04 08:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAX');
exec add_seats(fid_seq.currval, 10, 6);

INSERT INTO Flights (FID, flight_no, dep_date, dep_airport, arrival_date, dest_airport)
VALUES (fid_seq.NEXTVAL, 'MNO005', TO_DATE('2023-08-03 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL', TO_DATE('2023-08-03 22:55:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAS');
exec add_seats(fid_seq.currval, 10, 6);

INSERT INTO Flights (FID, flight_no, dep_date, dep_airport, arrival_date, dest_airport)
VALUES (fid_seq.NEXTVAL, 'PQR006', TO_DATE('2023-08-04 05:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAS', TO_DATE('2023-08-04 07:06:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAX');
exec add_seats(fid_seq.currval, 10, 6);

SHOW ERRORS;

-- Tickets / Legs ----------------------------------------------------------

	INSERT INTO Legs (FID, ticket_no, seat_no)
	VALUES (1000, ticket_seq.NEXTVAL, 4);

    DELETE FROM seats
    WHERE FID = 1000 AND seat_no = 4;

    INSERT INTO Tickets (ticket_no, cust_id, purchase_date, price)
    VALUES (ticket_seq.CURRVAL, 500, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 100.00);

	INSERT INTO Legs (FID, ticket_no, seat_no)
	VALUES (1001, ticket_seq.NEXTVAL, 3);

    DELETE FROM seats
    WHERE FID = 1001 AND seat_no = 3;

    INSERT INTO Tickets (ticket_no, cust_id, purchase_date, price)
    VALUES (ticket_seq.CURRVAL, 501, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 100.00);

	INSERT INTO Legs (FID, ticket_no, seat_no)
	VALUES (1002, ticket_seq.NEXTVAL, 1);

    DELETE FROM seats
    WHERE FID = 1002 AND seat_no = 1;

    INSERT INTO Tickets (ticket_no, cust_id, purchase_date, price)
    VALUES (ticket_seq.CURRVAL, 502, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 100.00);

	INSERT INTO Legs (FID, ticket_no, seat_no)
	VALUES (1003, ticket_seq.NEXTVAL, 60);

    DELETE FROM seats
    WHERE FID = 1003 AND seat_no = 60;

    INSERT INTO Tickets (ticket_no, cust_id, purchase_date, price)
    VALUES (ticket_seq.CURRVAL, 503, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 125.00);

	INSERT INTO Legs (FID, ticket_no, seat_no)
	VALUES (1004, ticket_seq.NEXTVAL, 15);

    DELETE FROM seats
    WHERE FID = 1004 AND seat_no = 15;

    INSERT INTO Tickets (ticket_no, cust_id, purchase_date, price)
    VALUES (ticket_seq.CURRVAL, 504, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 75.00);

	INSERT INTO Legs (FID, ticket_no, seat_no)
	VALUES (1005, ticket_seq.NEXTVAL, 7);

    DELETE FROM seats
    WHERE FID = 1005 AND seat_no = 7;

    INSERT INTO Tickets (ticket_no, cust_id, purchase_date, price)
    VALUES (ticket_seq.CURRVAL, 505, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 85.00);

COMMIT;

SHOW ERRORS;