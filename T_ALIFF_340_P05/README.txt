
-------------------------------------------------------------------------------------
-- YOU CAN RUN 'exec cmd(1,12)' TO LOAD AIRPORTS, CUSTOMERS, FLIGHTS, AND FIND A SEAT

-- THEN YOU CAN RUN 'exec cmd(13,17)' TO TEST DIFFERENT NUMBERS OF RESERVATIONS,
-- OR YOU CAN RUN THEM INDIVIDUALLY (14,14), ETC. I DID NOT SEPARATE EVERYTHING OUT
-- INTO ISOLATED TEST CASES. I DID LAST TIME ON P04, AND A LOT OF GOOD IT DID ME.

-- FOR THE OLD RESERVATION FUNCTION, YOU NEED TO RUN 'exec cmd(18,19)' TO LOAD A CUSTOMER FIRST
-------------------------------------------------------------------------------------


-- USAGE:
--
-- Command Table
-- -------------
-- [cmd_ID] is a key representing the corresponding row in the Sim_Data table
-- [cmd] is a 3-character string representing the desired operation
-- Possible operations are ['add'] ['scd'] ['fnd'] ['res'] ['old_res']
--
-- Sim_Data Table
-- --------------
-- Each row represents data to be processed by the corresponding [cmd_ID]/[cmd]
--
--
-- Execute commands on a range of rows by calling the cmd function:
-- ----------------------------------------------------------------
-- [exec cmd(<first row>, <final row>)]