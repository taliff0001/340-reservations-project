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

COMMIT;


-- AIRPORTS

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

-- FLIGHTS

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

-- CUSTOMERS

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


INSERT INTO Command (cmd_id, cmd) VALUES (13, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (13, 1, 'customer', '104', 'John', 'Holmes', '2500');

-- RESERVATIONS

-- One leg
INSERT INTO Command (cmd_id, cmd) VALUES (14, 'res_P05');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2)
VALUES (14, 1, '100', '1001');
-- Two legs
INSERT INTO Command (cmd_id, cmd) VALUES (15, 'res_P05');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (15, 1, '101', '1002', '1003');
-- Three legs
INSERT INTO Command (cmd_id, cmd) VALUES (16, 'res_P05');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (16, 1, '102', '1002', '1003', '1004');
-- Three legs fail
INSERT INTO Command (cmd_id, cmd) VALUES (17, 'res_P05');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (17, 1, '103', '1003', '1004', '1005');

INSERT INTO Command (cmd_id, cmd) VALUES (18, 'fnd');
INSERT INTO Sim_Data (cmd_id, item_no, p1)
VALUES (18, 1, '1001');

COMMIT;

SHOW ERRORS;

-- EXTRA DATA FOR TESTING --
/*
insert into airports values ('RIC', 'Richmond', 'VA');
insert into airports values ('BWI', 'Baltimore', 'MD');
insert into airports values ('MDT', 'Harrisburg', 'PA');
insert into airports values ('CVG', 'Cincinnatti', 'OH');
insert into airports values ('DFW', 'Dallas', 'TX');
insert into airports values ('SNA', 'Orange County', 'CA');
insert into airports values ('LAX', 'Los Angeles', 'CA');
insert into airports values ('LAS', 'Las Vegas', 'NV');


insert into customers values(102,'Ron','Jeremy', 2000);
insert into customers values(103,'John','Holms', 2000);
insert into customers values(104,'Muhatma','Ghandi', 2000);
insert into customers values(105,'Kill','Yourself', 2000);
insert into customers values(106,'Lauryn','Hill', 2000);

COMMIT;

*/