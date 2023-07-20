DROP TABLE Sim_Data;
DROP TABLE Command;

CREATE TABLE Command (
  cmd_id SMALLINT PRIMARY KEY,
  cmd CHAR(3)
);

CREATE TABLE Sim_Data (
  cmd_id SMALLINT,
  item_no SMALLINT,
  p1 VARCHAR2(10),
  p2 VARCHAR2(10),
  p3 VARCHAR2(10),
  p4 VARCHAR2(10),
  p5 VARCHAR2(10),
  p6 VARCHAR2(10),
  p7 VARCHAR2(10),
  PRIMARY KEY (cmd_id, item_no),
  FOREIGN KEY (cmd_id) REFERENCES Command(cmd_id)
);

COMMIT;

INSERT INTO command (cmd_id, cmd) VALUES (1,'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (1, 1, 'airport', 'DTW', 'Detroit', 'MI');

INSERT INTO Command (cmd_id, cmd) VALUES (2, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (2, 1, 'airport', 'ATL', 'Atlanta', 'GA');

INSERT INTO Command (cmd_id, cmd) VALUES (3, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (3, 1, 'customer', '100', 'Don', 'Draper', '1000');

INSERT INTO Command (cmd_id, cmd) VALUES (4, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (4, 1, '1001', '4281', '8/1/2023', 'DTW', '8/1/2023', 'ATL', '500');

INSERT INTO Command (cmd_id, cmd) VALUES (5, 'fnd');
INSERT INTO Sim_Data (cmd_id, item_no, p1)
VALUES (5, 1, '1001');

INSERT INTO Command (cmd_id, cmd) VALUES (6, 'res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (6, 1, '100', '1001', '1');

insert into airports values ('RIC', 'Richmond', 'VA');
insert into airports values ('BWI', 'Baltimore', 'MD');
insert into airports values ('MDT', 'Harrisburg', 'PA');
insert into airports values ('CVG', 'Cincinnatti', 'OH');
insert into airports values ('DFW', 'Dallas', 'TX');
insert into airports values ('SNA', 'Orange County', 'CA');
insert into airports values ('LAX', 'Los Angeles', 'CA');
insert into airports values ('LAS', 'Las Vegas', 'NV');


INSERT INTO Command (cmd_id, cmd) VALUES (7, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (7, 1, '1002', '8930', '8/1/2023', 'RIC', '9/1/2023', 'MDT', '325');

INSERT INTO Command (cmd_id, cmd) VALUES (8, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (8, 1, '1003', '6928', '8/1/2023', 'MDT', '8/1/2023', 'CVG', '250');

INSERT INTO Command (cmd_id, cmd) VALUES (9, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (9, 1, 'customer', '101', 'Notorious', 'B.I.G.', '1100');

COMMIT;