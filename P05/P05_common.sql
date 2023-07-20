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


COMMIT;