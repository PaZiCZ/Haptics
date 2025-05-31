% Function to combine the tables from sessions 1-5 and sessions 7-8 for Task 1 and Task 2
function completeDataTables(postProcessingFolder)

    % List of volunteers (1 to 12)
    volunteers = 1:12;

    % Create directories for complete Task 1 and Task 2 data if they don't exist
    completeDataforTask1Dir = fullfile(postProcessingFolder, 'completeDataforTask1');
    completeDataforTask2Dir = fullfile(postProcessingFolder, 'completeDataforTask2');
    
    % Create the directories if they don't exist
    if ~exist(completeDataforTask1Dir, 'dir')
        mkdir(completeDataforTask1Dir);
        disp(['Created folder for Task 1 data: ', completeDataforTask1Dir]);
    end
    
    if ~exist(completeDataforTask2Dir, 'dir')
        mkdir(completeDataforTask2Dir);
        disp(['Created folder for Task 2 data: ', completeDataforTask2Dir]);
    end

    % Loop through each volunteer and combine the data for Task 1 and Task 2
    for volunteer = volunteers
        % Paths to the existing data for Task 1 (sessions 1-5) and Task 1 (sessions 7-8)
        task1DataPath1_5 = fullfile(postProcessingFolder, sprintf('DataforTask1/Volunteer_%d_DataforTask1.xlsx', volunteer));
        task1DataPath7_8 = fullfile(postProcessingFolder, sprintf('DataforTask1_7_8/Volunteer_%d_DataforTask1.xlsx', volunteer));

        % Load the data for Task 1 (sessions 1-5) and Task 1 (sessions 7-8)
        task1Data1_5 = readtable(task1DataPath1_5);
        task1Data7_8 = readtable(task1DataPath7_8);

        % Delete the slope and Intersection columns of task1Data7_8
        task1Data7_8 = removevars(task1Data7_8, 'Slope');
        task1Data7_8 = removevars(task1Data7_8, 'Intersection');


        % Combine the Task 1 data: append the rows from task1Data7_8 (keeping headers) to task1Data1_5
        task1DataCombined = [task1Data1_5; task1Data7_8]; % Keep headers for task1Data7_8

        % Save the combined data for Task 1 for the current volunteer in the Task 1 folder
        task1CombinedFileName = fullfile(completeDataforTask1Dir, sprintf('Volunteer_%d_DataforTask1_combined.xlsx', volunteer));
        writetable(task1DataCombined, task1CombinedFileName);
        disp(['Saved combined Task 1 data for Volunteer ', num2str(volunteer), ' to: ', task1CombinedFileName]);

        % Repeat the same process for Task 2
        task2DataPath1_5 = fullfile(postProcessingFolder, sprintf('DataforTask2/Volunteer_%d_DataforTask2.xlsx', volunteer));
        task2DataPath7_8 = fullfile(postProcessingFolder, sprintf('DataforTask2_7_8/Volunteer_%d_DataforTask2.xlsx', volunteer));

        % Load the data for Task 2 (sessions 1-5) and Task 2 (sessions 7-8)
        task2Data1_5 = readtable(task2DataPath1_5);
        task2Data7_8 = readtable(task2DataPath7_8);

        % Combine the Task 2 data: append the rows from task2Data7_8 (keeping headers) to task2Data1_5
        task2DataCombined = [task2Data1_5; task2Data7_8]; % Keep headers for task2Data7_8

        % Save the combined data for Task 2 for the current volunteer in the Task 2 folder
        task2CombinedFileName = fullfile(completeDataforTask2Dir, sprintf('Volunteer_%d_DataforTask2_combined.xlsx', volunteer));
        writetable(task2DataCombined, task2CombinedFileName);
        disp(['Saved combined Task 2 data for Volunteer ', num2str(volunteer), ' to: ', task2CombinedFileName]);
    end

    disp('All individual volunteer data combined and saved in their respective folders!');
end