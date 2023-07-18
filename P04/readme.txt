USAGE
-----

To perform the test operations, place the scripts in the same directory and run P04_ctrl.sql. That will load the first five records into the Sim_Data table along with the corresponding commands. The remaining data for the three test procedures can be copy/pasted from the comments in P04_ctrl. To reload and run the next sequence of commands, re-execute P04_ctrl to drop/load the schema and then copy/paste the next section from the comments.


Command Table
-------------
[cmd_ID] is a key representing the corresponding row in the Sim_Data table
[cmd] is a 3-character string representing the desired operation
Possible operations are ['add'] ['scd'] ['fnd'] ['res']

Sim_Data Table
--------------
Each row represents data to be processed by the corresponding [cmd_ID]/[cmd]

CMD function:
----------------------------------------------------------------
[exec cmd(<first row>, <final row>)]