% Main function to process data and generate the tables for each volunteer and session
function createDataTables(saveFolder, postProcessingFolder)

    % List of volunteers and sessions
    volunteers = 1:12; % Volunteers (1 to 12)
    sessions = [1, 2, 3, 4, 5]; % Available sessions

    % Initialize an empty table to store all results
    allVolunteersTable = table();

    % Define the correct guidance methods and parallel tasks based on the Excel data
    guidance_methods_correct = {... 
        'Haptic + Visual', 'Haptic', 'Visual', ... % Session 1
        'Visual', 'Haptic + Visual', 'Haptic', ... % Session 2
        'Haptic', 'Visual', 'Haptic + Visual', ... % Session 3
        'Haptic + Visual', 'Haptic', 'Visual', ... % Session 4
        'Visual', 'Haptic + Visual', 'Haptic' ...  % Session 5
    };

    parallel_tasks_task1 = [0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1];
    parallel_tasks_task2 = [0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1];


    % Loop through all volunteers
    for volunteer = volunteers
        % Initialize tables for each volunteer with consistent column names
        task1Table = table(...
            NaN(15, 1), ... % Tester number placeholder
            NaN(15, 1), ... % Session number placeholder
            strings(15, 1), ... % Guidance method placeholder
            NaN(15, 1), ... % Parallel task placeholder
            NaN(15, 1), ... % AE values placeholder
            NaN(15, 1), ... % RT values placeholder
            NaN(15, 1), ... % Workload values placeholder
            'VariableNames', {'Tester', 'Session', 'GuidanceMethod', 'ParallelTask', 'AE', 'RT(s)', 'Workload'});  % Column names
        
        % Fill the GuidanceMethod and ParallelTask columns
        task1Table.GuidanceMethod = guidance_methods_correct(:);

        task2Table = task1Table;  % Initialize task2Table with the same structure

        % Elimina la columna RT de task2Table
        task2Table = removevars(task2Table, 'RT(s)');
        
        task1Table.ParallelTask = parallel_tasks_task1(:);  % Parallel task for each session
        task2Table.ParallelTask = parallel_tasks_task2(:);  % Parallel task for each session

        % Initialize an array to store the AE values for all 15 rows (one per session)
        AE_task1_all = NaN(15, 1);  % This will hold 15 AE values for task 1
        RT_task1_all = NaN(15, 1);  % Hold RT values
        AE_task2_all = NaN(15, 1);  % This will hold 15 AE values for task 2
        WL_task1_all = NaN(15, 1);  % Workload values for Task 1
        WL_task2_all = NaN(15, 1);  % Workload values for Task 2

        % Loop through all sessions
        for session = sessions
            % Initialize the session data (3 rows per session)
            sessionRows = (session-1)*3 + 1 : session*3;  % 3 rows per session
            
            % Fill the Session column (3 rows per session with the same session number)
            task1Table.Session(sessionRows) = repmat(session, 3, 1);
            task2Table.Session(sessionRows) = repmat(session, 3, 1);

            % Fill the TesterNumber column (same number for all rows in this session)
            task1Table.Tester(sessionRows) = repmat(volunteer, 3, 1);  % Assign volunteer number to TesterNumber
            task2Table.Tester(sessionRows) = repmat(volunteer, 3, 1);  % Assign volunteer number to TesterNumber

            % Determine the folder name and the paths of the CSV files for Task 1 and Task 2
            folderName = sprintf('te%dno%d', volunteer, session);
            csvFilesTask1 = dir(fullfile(saveFolder, folderName, 'resultsa*.csv'));
            csvFilesTask2 = dir(fullfile(saveFolder, folderName, 'resultsT2b*.csv'));
            csvFilesWorkload = dir(fullfile(saveFolder, folderName, 'workload.csv'));

            if ~isempty(csvFilesWorkload)
                workloadData = readmatrix(fullfile(csvFilesWorkload.folder, csvFilesWorkload.name));
                WL_task1_all(sessionRows) = workloadData(1:3, 1);  % columna 1 = Task 1
                WL_task2_all(sessionRows) = workloadData(1:3, 2);  % columna 2 = Task 2
            else
                WL_task1_all(sessionRows) = NaN;
                WL_task2_all(sessionRows) = NaN;
            end

            % Get data for Task 1 (calculate AE and RT average from the 3 sessions)
            AE_task1 = NaN(1, 3); % Initialize array for AE data from the 3 files
            RT_task1 = NaN(1, 3); % Initialize array for RT data from the 3 files
            for i = 1:length(csvFilesTask1)
                data = readtable(fullfile(csvFilesTask1(i).folder, csvFilesTask1(i).name));
                AE_task1(i) = mean(data.AE2_V_, 'omitnan'); % Calculate the AE average for each file
                RT_task1(i) = mean(data.RTs_s_, 'omitnan'); % Calculate the RT average for each file (Time to Reach Target Position)
            end

            % Get data for Task 2 (take the 3 AE values already calculated, 1 per session)
            AE_task2 = NaN(1, 3);  % Initialize array for the 3 AE values for Task 2
            for i = 1:length(csvFilesTask2)
                data = readtable(fullfile(csvFilesTask2(i).folder, csvFilesTask2(i).name));
                AE_task2(i) = data.AE2_V_(1);  % Take the AE value for Task 2 from each session
            end

            % Insert AE and RT values into the accumulated arrays (for task 1)
            AE_task1_all(sessionRows) = AE_task1(:);  % Store AE values
            RT_task1_all(sessionRows) = RT_task1(:);  % Store RT values
            AE_task2_all(sessionRows) = AE_task2(:);  % Store AE values for task 2
        end
        
        % After all sessions, assign the accumulated AE values to the task tables
        task1Table.AE = AE_task1_all;  % Add AE values to Task 1 table
        task1Table.('RT(s)') = RT_task1_all;  % Add RT values to Task 1 table
        task2Table.AE = AE_task2_all;  % Add AE values to Task 2 table
        task1Table.Workload = WL_task1_all; % Add Workload values to Task 1 table
        task2Table.Workload = WL_task2_all; % Add Workload values to Task 2 table

        % Create directories for Task 1 and Task 2 values
        DataforTask1Dir = fullfile(postProcessingFolder, 'DataforTask1');
        DataforTask2Dir = fullfile(postProcessingFolder, 'DataforTask2');

        % Check if directories exist, create if they don't
        if ~exist(DataforTask1Dir, 'dir')
            mkdir(DataforTask1Dir);  % Create folder for Task 1 AE values if it doesn't exist
            disp(['Created folder for Task 1: ', DataforTask1Dir]);
        end
        
        if ~exist(DataforTask2Dir, 'dir')
            mkdir(DataforTask2Dir);  % Create folder for Task 2 AE values if it doesn't exist
            disp(['Created folder for Task 2: ', DataforTask2Dir]);
        end

        % Save each volunteer's table for Task 1 and Task 2 in the DataforTask1 and DataforTask2 directories
        task1FileName = sprintf('Volunteer_%d_DataforTask1.xlsx', volunteer);
        task2FileName = sprintf('Volunteer_%d_DataforTask2.xlsx', volunteer);

        % Save Task 1 and Task 2 AE data directly in the DataforTask1 and DataforTask2 folders
        writetable(task1Table, fullfile(DataforTask1Dir, task1FileName));
        writetable(task2Table, fullfile(DataforTask2Dir, task2FileName));
    end
end