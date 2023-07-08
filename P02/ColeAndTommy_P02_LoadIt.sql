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

-- customer 1 : WOULD GET ID 500
INSERT INTO Customers (first_name, last_name, balance) 
VALUES ('Cole', 'Daniels', 150.00);

-- customer 2: WOULD GET ID 501
INSERT INTO Customers (first_name, last_name, balance)
VALUES ('Tommy', 'Aliff', 250.00);

insert into customers (first_name, last_name)
values ('Burt', 'Reynolds');


-- FLIGHTS --------------------------------------------------------------


INSERT INTO Flights (dep_date, dep_airport, arrival_date, dest_airport)
VALUES (TO_DATE('2023-08-03 05:48:00', 'YYYY-MM-DD HH24:MI:SS'), 'RIC', TO_DATE('2023-08-03 07:29:00', 'YYYY-MM-DD HH24:MI:SS'), 'DTW');

INSERT INTO Flights (dep_date, dep_airport, arrival_date, dest_airport)
VALUES (TO_DATE('2023-08-10 05:20:00', 'YYYY-MM-DD HH24:MI:SS'), 'DTW', TO_DATE('2023-08-10 07:16:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL');

INSERT INTO Flights (dep_date, dep_airport, arrival_date, dest_airport)
VALUES (TO_DATE('2023-08-10 08:04:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL', TO_DATE('2023-08-10 09:40:00', 'YYYY-MM-DD HH24:MI:SS'), 'RIC');

INSERT INTO Flights (dep_date, dep_airport, arrival_date, dest_airport)
VALUES (TO_DATE('2023-08-04 07:16:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL', TO_DATE('2023-08-04 08:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAX');

INSERT INTO Flights (dep_date, dep_airport, arrival_date, dest_airport)
VALUES (TO_DATE('2023-08-03 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'ATL', TO_DATE('2023-08-03 22:55:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAS');

INSERT INTO Flights (dep_date, dep_airport, arrival_date, dest_airport)
VALUES (TO_DATE('2023-08-04 05:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAS', TO_DATE('2023-08-04 07:06:00', 'YYYY-MM-DD HH24:MI:SS'), 'LAX');

SHOW ERRORS;

-- Tickets / Legs ----------------------------------------------------------

INSERT INTO Tickets (cust_id, purchase_date, price)
VALUES (500, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 100.00);

INSERT INTO Legs (FID, ticket_no, seat_no)
VALUES (1000, 4000, 4);

INSERT INTO Tickets (cust_id, purchase_date, price) 
VALUES (501, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 100.00);

INSERT INTO Legs (FID, ticket_no, seat_no)
VALUES (1001, 4001, 3);

INSERT INTO Tickets (cust_id, purchase_date, price) 
VALUES (501, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 100.00);

INSERT INTO Legs (FID, ticket_no, seat_no)
VALUES (1002, 4002, 1);

INSERT INTO Tickets (cust_id, purchase_date, price) 
VALUES (500, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 125.00);

INSERT INTO Legs (FID, ticket_no, seat_no)
VALUES (1003, 4003, 60);

INSERT INTO Tickets (cust_id, purchase_date, price) 
VALUES (501, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 75.00);

INSERT INTO Legs (FID, ticket_no, seat_no)
VALUES (1004, 4004, 15);

INSERT INTO Tickets (cust_id, purchase_date, price) 
VALUES (501, TO_DATE('2023-04-04 13:24:00', 'YYYY-MM-DD HH24:MI:SS'), 85.00);

INSERT INTO Legs (FID, ticket_no, seat_no)
VALUES (1005, 4004, 7);

COMMIT;

SHOW ERRORS;



