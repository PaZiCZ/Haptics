Explanation of the Various Functions for Data Postprocessing:

-Function createDataTables:

This function simply creates two data tables for each volunteer, one for task 1 and another for task 2, using the conditions for each session (specifically sessions 1 to 5, since the conditions are the same for all volunteers), guidance method, and parallel task. It compiles the mean data for average error, reaction time, and workload. For task 2, only average error and workload are considered.

-Function createDataTables_7_8:

This function performs the same process as "createDataTables" but for sessions 7 and 8. It was separated to avoid excessively long functions.

-Function completeDataTables:

This function merges the previously created tables, resulting in two comprehensive tables for each volunteer, one for task 1 and one for task 2, containing all session data.

-Functions getAEGraphs, getRTGraphs, getWorkloadGraphs, and getIDGraphs:

These functions generate the graphs for each volunteer, as well as the overall means for all volunteers, for the different parameters (AE, RT, Workload, and Fitts’ Law parameters). The getIDGraphs function first inserts the slope and intercept parameters into the completeDataTables and then generates the corresponding graphs.

-Function test:

This function creates the postprocessing data folder and runs all the functions mentioned above.