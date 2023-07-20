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


CREATE OR REPLACE PROCEDURE seats_pkg_test -- Use -1 as 3rd parameter to test 2
(FID_1 IN NUMBER, FID_2 IN NUMBER, FID_3 IN NUMBER)
IS
    seat_varray find_yo_seats.mo_seats_holder;
BEGIN
    IF FID_3 = -1 THEN
    seat_varray := find_yo_seats.find_mo_seats(FID_1, FID_2);
    ELSE
    seat_varray := find_yo_seats.find_mo_seats(FID_1, FID_2, FID_3);
    END IF;
    
    FOR i IN 1..seat_varray.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('FID: ' || seat_varray(i).FID || ', Seat_no: ' || seat_varray(i).Seat_no);
    END LOOP;
END;
/
