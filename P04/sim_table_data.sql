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

INSERT INTO Command (cmd_id, cmd) VALUES (1, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (1, 1, 'airport', 'ROA', 'Roanoke', 'VA');

INSERT INTO Command (cmd_id, cmd) VALUES (2, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (2, 1, 'airport', 'CLT', 'Charlotte', 'NC');

INSERT INTO Command (cmd_id, cmd) VALUES (3, 'add');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (3, 1, 'customer', '100', 'Mary', 'Smith', '1000');

INSERT INTO Command (cmd_id, cmd) VALUES (4, 'scd');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (4, 1, '2000', '1284', '7/1/2023', 'ROA', '7/1/2023', 'CLT', '125');

INSERT INTO Command (cmd_id, cmd) VALUES (5, 'fnd');
INSERT INTO Sim_Data (cmd_id, item_no, p1)
VALUES (5, 1, '2000');

INSERT INTO Command (cmd_id, cmd) VALUES (6, 'res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (6, 1, '100', '2000', '1');

COMMIT;

-- ------------------------------------------------------------------------

-- NEW CUSTOMER ATTEMPTS TO PURCHASE A RESERVED SEAT

INSERT INTO command (cmd_id, cmd) VALUES (7, 'add');
INSERT INTO sim_data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (7, 1, 'customer', '101', 'Jesus H', 'Christ', '700');

INSERT INTO command (cmd_id, cmd) VALUES (8,'res');
INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (8, 1, '100', '2000', '1');
        
COMMIT;

-- -----------------------------------------------------------------------
        
-- CUSTOMER ATTEMPTS TO PURCHASE A SECOND TICKET IN A DAY
        
INSERT INTO command (cmd_id, cmd) VALUES (9,'res');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (9, 1, '100', '2000', '2');

COMMIT;
        
-- -----------------------------------------------------------------------
/*

EXTRA INSERT STATEMENTS

INSERT INTO Command (cmd_id, cmd) VALUES (10, 'add');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4)
VALUES (10, 1, 'airport', 'ATL', 'Atlanta', 'GA');


-- ------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (11, 'add');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5)
VALUES (11, 1, 'customer', '99', 'Don', 'Draper', '1000');


-- ------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (12, 'scd');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3, p4, p5, p6, p7)
VALUES (12, 1, '2001', '1284', '8/1/2023', 'DTW', '8/1/2023', 'ATL', '500');


-- ------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (13, 'res');

INSERT INTO Sim_Data (cmd_id, item_no, p1, p2, p3)
VALUES (13, 1, '99', '2001', '5');


-- ------------------------------------------------------------------------

INSERT INTO Command (cmd_id, cmd) VALUES (14, 'fnd');

INSERT INTO Sim_Data (cmd_id, item_no, p1)
VALUES (14, 1, '2000');


COMMIT;
*/




