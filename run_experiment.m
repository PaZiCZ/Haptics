
% run_experiment.m
% This file runs the experiment for a specific tester (participant) and experiment_no (session).
% It reads settings for that tester/experiment_no from the settings_table.csv file.

% during the experiment, participant should listen to white noise:
% https://www.youtube.com/watch?v=8fVnY3Q_iW8 
% it is necessary because servos and sliding element movement can be heard


% Define tester and experiment_no (participant and session number)
tester = 7;        % Set the tester number (participant, e.g., 1) (7 for short T2)
experiment_no = 2; % Set the experiment number (session number, e.g., 2) (7-1 only haptics, 7-2 only visual, 7-3 both)

testcase="te"+tester+"no"+experiment_no; 

saveFolder = fullfile('E:\Thesis255678\measurement', testcase);

% Ensure the folder exists; create it if it doesn't
if ~isfolder(saveFolder)
    mkdir(saveFolder);
    disp(['Created folder: ', saveFolder]);
else
    disp(['Folder already exists: ', saveFolder]);
    disp('DO NOT CONTINUE');
end

% Load experiment settings from a table (assumes the table is named 'settings_table.csv')
settings_table = readtable('settings_table.csv');  % Adjust file name as necessary

% Find the row that corresponds to the given tester and experiment_no
row = settings_table(settings_table.tester == tester & settings_table.experiment_no == experiment_no, :);

% Check if the row is empty (i.e., no matching entry for the tester/experiment_no)
if isempty(row)
    error('No settings found for tester %d and experiment_no %d.', tester, experiment_no);
end

% Read the experiment settings from the selected row
variant1 = row.variant1(1);      % Variant for feedback settings (variant 1)
variant2 = row.variant2(1);      % Variant for feedback settings (variant 2)
variant3 = row.variant3(1);      % Variant for feedback settings (variant 3)

% Assign flags for haptic and visual feedback for each variant
haptic1 = row.haptic1(1);  % 1 for haptic feedback, 0 for no haptic (for variant 1)
visual1 = row.visual1(1);  % 1 for visual feedback, 0 for no visual (for variant 1)

haptic2 = row.haptic2(1);  % 1 for haptic feedback, 0 for no haptic (for variant 2)
visual2 = row.visual2(1);  % 1 for visual feedback, 0 for no visual (for variant 2)

haptic3 = row.haptic3(1);  % 1 for haptic feedback, 0 for no haptic (for variant 3)
visual3 = row.visual3(1);  % 1 for visual feedback, 0 for no visual (for variant 3)

T1paralel1 = row.T1paralel1(1);
T2paralel1 = row.T2paralel1(1);

T1paralel2 = row.T1paralel2(1);
T2paralel2 = row.T2paralel2(1);

T1paralel3 = row.T1paralel3(1);
T2paralel3 = row.T2paralel3(1);

% Call your main experiment function for each variant (replace with your own logic)
% Example: running the experiment for variant 1, 2, and 3
haptic = {haptic1, haptic2, haptic3}; 
visual = {visual1, visual2, visual3};
variant = {variant1, variant2, variant3};
T1paralel = {T1paralel1, T1paralel2, T1paralel3};
T2paralel = {T2paralel1, T2paralel2, T2paralel3};
% Initialize workload matrix with zeros (assuming 3 repetitions)
workload1 = zeros(1, length(haptic));
workload2 = zeros(1, length(haptic));
for i = 1:length(haptic)
    
    PrvniCastVisual(tester, experiment_no, haptic{i}, visual{i}, T1paralel{i}, i, testcase, saveFolder);
    workload1(i) = input(sprintf('Please enter a number for workload: '));
    DruhaCastVisual(tester, experiment_no, haptic{i}, visual{i}, T2paralel{i}, i, testcase, variant{i}, saveFolder);
    workload2(i) = input(sprintf('Please enter a number for workload: '));
end

% Create a table with headers
repetitions = 1:length(haptic); % Column headers (1,2,3,...)

% Create a matrix by combining workload1 and workload2 as columns
workloadMatrix = [workload1', workload2']; % Transpose to make each variable a column

T = array2table(workloadMatrix, 'VariableNames', {'Workload1', 'Workload2'}); % Corrected variable names

% Define CSV file name
csvFileName = fullfile(saveFolder, 'workload.csv');

% Save the table to CSV
writetable(T, csvFileName);

disp(['Workload matrix saved to ', csvFileName]);

% Moving paralel task files from Labview to Matlab test session folder
sourceFolder = 'C:\Users\simulator\Documents\LabVIEW Data';
filesToMove = {'Altitude.xlsx', 'Temperature.xlsx'};
for i = 1:length(filesToMove)
    sourceFile = fullfile(sourceFolder, filesToMove{i});
    destinationFile = fullfile(saveFolder, filesToMove{i});
    
    % Check if the file exists before moving
    if exist(sourceFile, 'file')
        movefile(sourceFile, destinationFile);
        fprintf('Moved: %s -> %s\n', sourceFile, destinationFile);
    else
        fprintf('File not found: %s\n', sourceFile);
    end
end

% test of results saving - Jan will add the code
% To evaluate that the generated tables are correct
savedfilestest(saveFolder);

% Optionally, save results or generate reports after the experiment
disp('Experiment completed.');

% Prompt volunteer for comments
volunteerComment = inputdlg({'Please enter your comments/observations about the experiment:'}, 'Experiment Feedback', [10 50]); 

% Save comments to a text file with timestamp
if ~isempty(volunteerComment)
    commentFilename = fullfile(saveFolder, ['ExperimentComments_', char(datetime('now','Format','yyyyMMdd_HHmmss')), '.txt']);
    fid = fopen(commentFilename, 'w');
    fprintf(fid, 'Experiment: %s\n', testcase);
    fprintf(fid, 'Repetition: %d\n', repetition);
    fprintf(fid, 'Date: %s\n\n', char(datetime('now','Format','dd-MMM-yyyy HH:mm:ss')));
    fprintf(fid, 'VOLUNTEER COMMENTS:\n%s', volunteerComment{1});
    fclose(fid);
    
    disp('Volunteer comments saved successfully.');
end

