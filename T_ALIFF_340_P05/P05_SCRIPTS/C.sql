DROP TABLE Sim_Data;
DROP TABLE Command;

CREATE TABLE Command (
  cmd_id SMALLINT PRIMARY KEY,
  cmd VARCHAR2(7)
);

CREATE TABLE Sim_Data (
  cmd_id SMALLINT,
  item_no SMALLINT,
  p1 VARCHAR2(12),
  p2 VARCHAR2(12),
  p3 VARCHAR2(12),
  p4 VARCHAR2(12),
  p5 VARCHAR2(12),
  p6 VARCHAR2(6),
  p7 VARCHAR2(6),
  PRIMARY KEY (cmd_id, item_no),
  FOREIGN KEY (cmd_id) REFERENCES Command(cmd_id)
);


-------------------------------------------------------------------------------------
-- YOU CAN RUN 'exec cmd(1,12)' TO LOAD AIRPORTS, CUSTOMERS, FLIGHTS, AND FIND A SEAT

-- THEN YOU CAN RUN 'exec cmd(13,17)' TO TEST DIFFERENT NUMBERS OF RESERVATIONS,
-- OR YOU CAN RUN THEM INDIVIDUALLY (14,14), ETC. I DID NOT SEPARATE EVERYTHING OUT
-- INTO ISOLATED TEST CASES. I DID LAST TIME ON P04, AND A LOT OF GOOD IT DID ME.

-- FOR THE OLD RESERVATION FUNCTION, YOU NEED TO RUN 'exec cmd(18,19)' TO LOAD A CUSTOMER FIRST
-------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------
-- AIRPORTS
-------------------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (1, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (1, 1, 'airport', 'DTW', 'Detroit', 'MI');

INSERT INTO Command (cmd_id, cmd) VALUES (2, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (2, 1, 'airport', 'ATL', 'Atlanta', 'GA');

INSERT INTO Command (cmd_id, cmd) VALUES (3, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (3, 1, 'airport', 'JFK', 'New York', 'NY');

INSERT INTO Command (cmd_id, cmd) VALUES (4, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (4, 1, 'airport', 'LAX', 'Los Angeles', 'CA');

-------------------------------------------------------------------------------------
-- FLIGHTS
-------------------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (5, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (5, 1, '1001', '4281', '8/1/2023', 'DTW', '8/1/2023', 'ATL', '500');

INSERT INTO Command (cmd_id, cmd) VALUES (6, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (6, 1, '1002', '4281', '8/1/2023', 'DTW', '8/1/2023', 'JFK', '550');

INSERT INTO Command (cmd_id, cmd) VALUES (7, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (7, 1, '1003', '4281', '8/1/2023', 'JFK', '8/1/2023', 'ATL', '650');

INSERT INTO Command (cmd_id, cmd) VALUES (8, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (8, 1, '1004', '4281', '8/1/2023', 'ATL', '8/2/2023', 'LAX', '750');

-------------------------------------------------------------------------------------
-- CUSTOMERS
-------------------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (9, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (9, 1, 'customer', '100', 'Don', 'Draper', '2500');

INSERT INTO Command (cmd_id, cmd) VALUES (10, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (10, 1, 'customer', '101', 'Notorious', 'B.I.G.', '2500');

INSERT INTO Command (cmd_id, cmd) VALUES (11, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (11, 1, 'customer', '102', 'Ron', 'Jeremy', '100');

INSERT INTO Command (cmd_id, cmd) VALUES (12, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (12, 1, 'customer', '103', 'Kelly', 'Clarkson', '2500');


-------------------------------------------------------------------------------------
-- RESERVATIONS FOR ONE TO THREE FLIGHTS --
-------------------------------------------------------------------------------------

-- One leg
INSERT INTO Command (cmd_id, cmd) VALUES (13, 'res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2)
VALUES (13, 1, '100', '1001');

-- Two legs
INSERT INTO Command (cmd_id, cmd) VALUES (14, 'res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (14, 1, '101', '1002', '1003');


-- Three legs FAILURE
INSERT INTO Command (cmd_id, cmd) VALUES (15, 'res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (15, 1, '102', '1002', '1003', '1004');


-- Three legs SUCCESS
INSERT INTO Command (cmd_id, cmd) VALUES (16, 'res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (16, 1, '103', '1002', '1003', '1004');

INSERT INTO Command (cmd_id, cmd) VALUES (17, 'fnd');
INSERT INTO Sim_Data (cmd_id, item_no, p1)
VALUES (17, 1, '1001');

-------------------------------------------------------------------------------------
-- OLD RESERVATION FUNCTION USING SEAT FOR INDIVIDUAL FLIGHT --
-------------------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (18, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (18, 1, 'customer', '104', 'Mitch', 'McConnell', '1200');

INSERT INTO Command (cmd_id, cmd) VALUES (19, 'old_res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (19, 1, '104', '1002', '7');
COMMIT;