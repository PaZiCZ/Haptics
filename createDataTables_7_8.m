% Main function to process data and generate the tables for each volunteer and session
function createDataTables_7_8(saveFolder, postProcessingFolder)

    % List of volunteers and sessions
    volunteers = 1:12; % Volunteers (1 to 12)
    sessions = [7, 8]; % Available sessions

    % Initialize an empty table to store all results
    allVolunteersTable = table();

    % Initialize summary tables for each metric
    all_AE_Task1     = table();  % Task 1 AE
    all_RT_Task1     = table();  % Task 1 RT
    all_WL_Task1     = table();  % Task 1 Workload
    all_Slope_Task1  = table();  % Task 1 Slope
    all_Inter_Task1  = table();  % Task 1 Intersection
    
    all_AE_Task2     = table();  % Task 2 AE
    all_WL_Task2     = table();  % Task 2 Workload

    % Guidance methods and Parallel tasks for each volunteer and each
    % session
    guidance_methods_volunteer1 = {...  
        'Haptic + Visual', 'Haptic', 'Visual', ... % Session 7, volunteer 1 
        'Haptic', 'Visual', 'Haptic + Visual', ... % Session 8, volunteer 1 
    };

    guidance_methods_volunteer2 = {...  
        'Haptic', 'Visual', 'Haptic + Visual', ... % Session 7, volunteer 2 
        'Visual', 'Haptic + Visual', 'Haptic', ... % Session 8, volunteer 2 
    };

    guidance_methods_volunteer3 = {...  
        'Visual', 'Haptic + Visual', 'Haptic', ... % Session 7, volunteer 3 
        'Haptic + Visual', 'Haptic', 'Visual', ... % Session 8, volunteer 3 
    };

    guidance_methods_volunteer4 = {...  
        'Haptic + Visual', 'Haptic', 'Visual', ... % Session 7, volunteer 4 
        'Haptic', 'Visual', 'Haptic + Visual', ... % Session 8, volunteer 4 

    };

    guidance_methods_volunteer5 = {...  
        'Haptic', 'Visual', 'Haptic + Visual', ... % Session 7, volunteer 5 
        'Visual', 'Haptic + Visual', 'Haptic', ... % Session 8, volunteer 5 
    };

    guidance_methods_volunteer6 = {...  
        'Visual', 'Haptic + Visual', 'Haptic', ... % Session 7, volunteer 6 
        'Haptic + Visual', 'Haptic', 'Visual', ... % Session 8, volunteer 6 
    };
    guidance_methods_volunteer7 = {...  
        'Visual', 'Haptic', 'Haptic + Visual', ... % Session 7, volunteer 7 
        'Haptic + Visual', 'Visual', 'Haptic', ... % Session 8, volunteer 7 
    };

    guidance_methods_volunteer8 = {...  
        'Haptic + Visual', 'Visual', 'Haptic', ... % Session 7, volunteer 8 
        'Haptic', 'Haptic + Visual', 'Visual', ... % Session 8, volunteer 8 
    };

    guidance_methods_volunteer9 = {...  
        'Haptic', 'Haptic + Visual', 'Visual', ... % Session 7, volunteer 9 
        'Visual', 'Haptic', 'Haptic + Visual', ... % Session 8, volunteer 9 
    };

    guidance_methods_volunteer10 = {...  
        'Visual', 'Haptic', 'Haptic + Visual', ... % Session 7, volunteer 10 
        'Haptic + Visual', 'Visual', 'Haptic', ... % Session 8, volunteer 10 
    };

    guidance_methods_volunteer11 = {...  
        'Haptic + Visual', 'Visual', 'Haptic', ... % Session 7, volunteer 11 
        'Haptic', 'Haptic + Visual', 'Visual', ... % Session 8, volunteer 11 
    };

    guidance_methods_volunteer12 = {...  
        'Haptic', 'Haptic + Visual', 'Visual', ... % Session 7, volunteer 12 
        'Visual', 'Haptic', 'Haptic + Visual', ... % Session 8, volunteer 12 
    };

    parallel_tasks_volunteer1_task1 = [1, 0, 1, 1, 0, 0]; 
    parallel_tasks_volunteer1_task2 = [0, 1, 0, 0, 1, 1];

    parallel_tasks_volunteer2_task1 = [1, 1, 0, 0, 1, 0]; 
    parallel_tasks_volunteer2_task2 = [0, 0, 1, 1, 0, 1];

    parallel_tasks_volunteer3_task1 = [1, 1, 0, 0, 1, 0]; 
    parallel_tasks_volunteer3_task2 = [0, 0, 1, 1, 0, 1];

    parallel_tasks_volunteer4_task1 = [0, 1, 0, 0, 1, 1]; 
    parallel_tasks_volunteer4_task2 = [1, 0, 1, 1, 0, 0];

    parallel_tasks_volunteer5_task1 = [0, 0, 1, 1, 0, 1]; 
    parallel_tasks_volunteer5_task2 = [1, 1, 0, 0, 1, 0];

    parallel_tasks_volunteer6_task1 = [0, 0, 1, 1, 0, 1]; 
    parallel_tasks_volunteer6_task2 = [1, 1, 0, 0, 1, 0];

    parallel_tasks_volunteer7_task1 = [0, 1, 0, 1, 1, 0]; 
    parallel_tasks_volunteer7_task2 = [1, 0, 1, 0, 0, 1];

    parallel_tasks_volunteer8_task1 = [0, 0, 1, 0, 1, 1];      
    parallel_tasks_volunteer8_task2 = [1, 1, 0, 1, 0, 0];      

    parallel_tasks_volunteer9_task1 = [0, 0, 1, 0, 1, 1];      
    parallel_tasks_volunteer9_task2 = [1, 1, 0, 1, 0, 0];      
    
    parallel_tasks_volunteer10_task1 = [1, 0, 1, 0, 0, 1];      
    parallel_tasks_volunteer10_task2 = [0, 1, 0, 1, 1, 0];      
    
    parallel_tasks_volunteer11_task1 = [1, 1, 0, 1, 0, 0];      
    parallel_tasks_volunteer11_task2 = [0, 0, 1, 0, 1, 1];      
    
    parallel_tasks_volunteer12_task1 = [1, 1, 0, 1, 0, 0];      
    parallel_tasks_volunteer12_task2 = [0, 0, 1, 0, 1, 1];

    % Loop through all volunteers
    for volunteer = volunteers
        % Initialize tables for each volunteer with consistent column names
        task1Table = table(... 
            NaN(6, 1), ... % Tester number placeholder
            NaN(6, 1), ... % Session number placeholder
            strings(6, 1), ... % Guidance method placeholder
            NaN(6, 1), ... % Parallel task placeholder
            NaN(6, 1), ... % AE values placeholder
            NaN(6, 1), ... % RT values placeholder
            NaN(6, 1), ... % Workload values placeholder
            NaN(6, 1), ... % Slope values placeholder
            NaN(6, 1), ... % Intersection values placeholder
            'VariableNames', {'Tester', 'Session', 'GuidanceMethod', 'ParallelTask', 'AE', 'RT(s)', 'Workload', 'Slope', 'Intersection'});  % Column names with TesterNumber first
        
        task2Table = task1Table;  % Initialize task2Table with the same structure
        
        % Delete the RT, Slope and Intersection columns of task2Table
        task2Table = removevars(task2Table, 'RT(s)');
        task2Table = removevars(task2Table, 'Slope');
        task2Table = removevars(task2Table, 'Intersection');

        AE_task1_all = NaN(6, 1);  % This will hold 6 AE values for task 1
        RT_task1_all = NaN(6, 1);  % This will hold 6 RT values for task 1
        AE_task2_all = NaN(6, 1);  % This will hold 6 AE values for task 2
        task1_workload = NaN(6, 1); % This will hold 6 Workload values for task 1
        task2_workload = NaN(6,1); % This will hold 6 Workload values for task 2
        task1_Slope = NaN(6,1); % This will hold 6 Slope values for task 1
        task1_Intersection = NaN(6,1); % This will hold 6 Intersection values for task 1

        % Loop through all sessions
        for session = sessions
            % Initialize the session data (3 rows per session)
            sessionRows = (session-7)*3 + 1 : (session-6)*3;  % 3 rows per session
            
            % Fill the Session column (3 rows per session with the same session number)
            task1Table.Session(sessionRows) = repmat(session, 3, 1);
            task2Table.Session(sessionRows) = repmat(session, 3, 1);

            % Fill the TesterNumber column (same number for all rows in this session)
            task1Table.Tester(sessionRows) = repmat(volunteer, 3, 1);  % Assign volunteer number to TesterNumber
            task2Table.Tester(sessionRows) = repmat(volunteer, 3, 1);  % Assign volunteer number to TesterNumber
            
            % Define the guidance method and parallel tasks for each volunteer for sessions 7 and 8
            guidance_methods_volunteer = eval(sprintf('guidance_methods_volunteer%d', volunteer));
            parallel_tasks_task1_volunteer = eval(sprintf('parallel_tasks_volunteer%d_task1', volunteer));
            parallel_tasks_task2_volunteer = eval(sprintf('parallel_tasks_volunteer%d_task2', volunteer));
            
            % Assign the correct guidance method and parallel task for this session
            if session == 7
                % For session 7, use the first 3 values in guidance_methods_volunteer
                task1Table.GuidanceMethod(sessionRows) = guidance_methods_volunteer(1:3);  % Guidance for Task 1
                task2Table.GuidanceMethod(sessionRows) = guidance_methods_volunteer(1:3);  % Guidance for Task 2
                
                % Assign parallel tasks for session 7 (first 3 values)
                task1Table.ParallelTask(sessionRows) = parallel_tasks_task1_volunteer(1:3);  % Parallel task for Task 1 (session 7)
                task2Table.ParallelTask(sessionRows) = parallel_tasks_task2_volunteer(1:3);  % Parallel task for Task 2 (session 7)
            elseif session == 8
                % For session 8, use the last 3 values in guidance_methods_volunteer
                task1Table.GuidanceMethod(sessionRows) = guidance_methods_volunteer(4:6);  % Guidance for Task 1
                task2Table.GuidanceMethod(sessionRows) = guidance_methods_volunteer(4:6);  % Guidance for Task 2
                
                % Assign parallel tasks for session 8 (last 3 values)
                task1Table.ParallelTask(sessionRows) = parallel_tasks_task1_volunteer(4:6);  % Parallel task for Task 1 (session 8)
                task2Table.ParallelTask(sessionRows) = parallel_tasks_task2_volunteer(4:6);  % Parallel task for Task 2 (session 8)
            end
    
            % Determine the folder name and the paths of the CSV files for Task 1 and Task 2
            folderName = sprintf('te%dno%d', volunteer, session);
            csvFilesTask1 = dir(fullfile(saveFolder, folderName, 'resultsa*.csv'));
            csvFilesTask2 = dir(fullfile(saveFolder, folderName, 'resultsT2b*.csv'));
            csvFilesWorkload = dir(fullfile(saveFolder, folderName, 'workload.csv'));
            csvFilesFitts = dir(fullfile(saveFolder, folderName, 'resultsd*.csv'));


            if ~isempty(csvFilesWorkload)
                workloadData = readmatrix(fullfile(csvFilesWorkload.folder, csvFilesWorkload.name));
                
                workload_task1 = workloadData(1:3, 1);  % column 1 = task 1
                workload_task2 = workloadData(1:3, 2);  % column 2 = task 2
                
                task1_workload(sessionRows) = workload_task1;
                task2_workload(sessionRows) = workload_task2;
            else
                task1_workload(sessionRows) = NaN;
                task2_workload(sessionRows) = NaN;
            end

            % Get data for Task 1 (calculate AE and RT averages from the 3 sessions)
            AE_task1 = NaN(1, 3); % Initialize array for AE data from the 3 files
            RT_task1 = NaN(1, 3); % Initialize array for RT data from the 3 files
            Slope_task1 = NaN(1, 3); % Initialize array for Slope data from the 3 files
            Intersection_task1 = NaN(1, 3); % Initialize array for Intersection data from the 3 files

            for i = 1:length(csvFilesTask1)
                data = readtable(fullfile(csvFilesTask1(i).folder, csvFilesTask1(i).name));
                data2 = readtable(fullfile(csvFilesFitts(i).folder, csvFilesFitts(i).name));
                AE_task1(i) = mean(data.AE2_V_, 'omitnan'); % Calculate the AE average for each Task 1 CSV file, ignoring NaN values
                RT_task1(i) = mean(data.RTs_s_, 'omitnan'); % Calculate the RT average for each Task 1 CSV file, ignoring NaN values
                Slope_task1(i) = data2.slope; % Take the Slope value from each session
                Intersection_task1(i) = data2.intersection_withMTAxis_; % Take the Intersection value from each session
            end

            % Get data for Task 2 (take the 3 AE values already calculated, 1 per session)
            AE_task2 = NaN(1, 3);  % Initialize array for the 3 AE values for Task 2
            for i = 1:length(csvFilesTask2)
                data = readtable(fullfile(csvFilesTask2(i).folder, csvFilesTask2(i).name));
                AE_task2(i) = data.AE2_V_(1);  % Take the AE value for Task 2 from each session
            end

            % Insert AE and RT values into the accumulated arrays (for task 1)
            AE_task1_all(sessionRows) = AE_task1(:);  % Store AE values for task 1
            RT_task1_all(sessionRows) = RT_task1(:);  % Store RT values for task 1
            task1_Slope(sessionRows) = Slope_task1(:); % Store Slope values for task 1
            task1_Intersection(sessionRows) = Intersection_task1(:); % Store Intersection values for task 1
            AE_task2_all(sessionRows) = AE_task2(:);  % Store AE values for task 2
        end
        
        % After all sessions, assign the accumulated AE and RT values to the task tables
        task1Table.AE = AE_task1_all;  % Add AE values to Task 1 table
        task1Table.('RT(s)') = RT_task1_all;  % Add RT values to Task 1 table
        task2Table.AE = AE_task2_all;  % Add AE values to Task 2 table
        task1Table.Workload = task1_workload;
        task2Table.Workload = task2_workload;
        task1Table.Slope = task1_Slope;
        task1Table.Intersection = task1_Intersection;

        % Create directories for Task 1 and Task 2 AE values for sessions 7
        % and 8
        DataforTask1Dir = fullfile(postProcessingFolder, 'DataforTask1_7_8');
        DataforTask2Dir = fullfile(postProcessingFolder, 'DataforTask2_7_8');

        % Check if directories exist, create if they don't
        if ~exist(DataforTask1Dir, 'dir')
            mkdir(DataforTask1Dir);  % Create folder for Task 1 Data if it doesn't exist
            disp(['Created folder for Task 1: ', DataforTask1Dir]);
        end
        
        if ~exist(DataforTask2Dir, 'dir')
            mkdir(DataforTask2Dir);  % Create folder for Task 2 AE values if it doesn't exist
            disp(['Created folder for Task 2: ', DataforTask2Dir]);
        end
        
        % Save each volunteer's table for Task 1 and Task 2 in the DataforTask1_7_8 and DataforTask2_7_8 directories
        task1FileName = sprintf('Volunteer_%d_DataforTask1.xlsx', volunteer);
        task2FileName = sprintf('Volunteer_%d_DataforTask2.xlsx', volunteer);

        % Save Task 1 and Task 2 data directly in the DataforTask1_7_8 and DataforTask2_7_8 folders
        writetable(task1Table, fullfile(DataforTask1Dir, task1FileName));
        writetable(task2Table, fullfile(DataforTask2Dir, task2FileName));

        % Generate summary rows for all metrics
        AE1 = nan(1,6); RT1 = nan(1,6); WL1 = nan(1,6); SLP1 = nan(1,6); INT1 = nan(1,6);
        AE2 = nan(1,6); WL2 = nan(1,6);

        methods1 = task1Table.GuidanceMethod;
        parallel1 = task1Table.ParallelTask;
        methods2 = task2Table.GuidanceMethod;
        parallel2 = task2Table.ParallelTask;

        for r = 1:6
            method1 = strtrim(methods1(r)); isP1_1 = parallel1(r)==1;
            method2 = strtrim(methods2(r)); isP1_2 = parallel2(r)==1;

            % Task 1 category index
            idx = find(strcmp(method1, {'Haptic', 'Haptic + Visual', 'Visual'}) & [isP1_1, isP1_1, isP1_1]);
            if isempty(idx), idx = find(strcmp(method1, {'Haptic', 'Haptic + Visual', 'Visual'}) & ~[isP1_1, isP1_1, isP1_1]) + 3; end

            if ~isempty(idx)
                AE1(idx)  = task1Table.AE(r);
                RT1(idx)  = task1Table.("RT(s)")(r);
                WL1(idx)  = task1Table.Workload(r);
                SLP1(idx) = task1Table.Slope(r);
                INT1(idx) = task1Table.Intersection(r);
            end

            idx2 = find(strcmp(method2, {'Haptic', 'Haptic + Visual', 'Visual'}) & [isP1_2, isP1_2, isP1_2]);
            if isempty(idx2), idx2 = find(strcmp(method2, {'Haptic', 'Haptic + Visual', 'Visual'}) & ~[isP1_2, isP1_2, isP1_2]) + 3; end

            if ~isempty(idx2)
                AE2(idx2) = task2Table.AE(r);
                WL2(idx2) = task2Table.Workload(r);
            end
        end

        % Append all metric rows
        varNames = {'Tester','H_P1','H+V_P1','V_P1','H_P0','H+V_P0','V_P0'};
        all_AE_Task1     = [all_AE_Task1;     array2table([volunteer AE1],  'VariableNames', varNames)];
        all_RT_Task1     = [all_RT_Task1;     array2table([volunteer RT1],  'VariableNames', varNames)];
        all_WL_Task1     = [all_WL_Task1;     array2table([volunteer WL1],  'VariableNames', varNames)];
        all_Slope_Task1  = [all_Slope_Task1;  array2table([volunteer SLP1], 'VariableNames', varNames)];
        all_Inter_Task1  = [all_Inter_Task1;  array2table([volunteer INT1], 'VariableNames', varNames)];
        all_AE_Task2     = [all_AE_Task2;     array2table([volunteer AE2],  'VariableNames', varNames)];
        all_WL_Task2     = [all_WL_Task2;     array2table([volunteer WL2],  'VariableNames', varNames)];
    end

    % Save all summary Excel files 
    summaryFolder = fullfile(postProcessingFolder, 'Metric_Summaries_By_Condition');
    if ~exist(summaryFolder, 'dir'), mkdir(summaryFolder); end

    writetable(all_AE_Task1,    fullfile(summaryFolder, 'Task1_AE.xlsx'));
    writetable(all_RT_Task1,    fullfile(summaryFolder, 'Task1_RT.xlsx'));
    writetable(all_WL_Task1,    fullfile(summaryFolder, 'Task1_Workload.xlsx'));
    writetable(all_Slope_Task1, fullfile(summaryFolder, 'Task1_Slope.xlsx'));
    writetable(all_Inter_Task1, fullfile(summaryFolder, 'Task1_Intersection.xlsx'));
    writetable(all_AE_Task2,    fullfile(summaryFolder, 'Task2_AE.xlsx'));
    writetable(all_WL_Task2,    fullfile(summaryFolder, 'Task2_Workload.xlsx'));
end

