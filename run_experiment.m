
% run_experiment.m
% This file runs the experiment for a specific tester (participant) and experiment_no (session).
% It reads settings for that tester/experiment_no from the settings_table.csv file.

% during the experiment, participant should listen to white noise:
% https://www.youtube.com/watch?v=8fVnY3Q_iW8 
% it is necessary because servos and sliding element movement can be heard


% Define tester and experiment_no (participant and session number)
tester = 7;        % Set the tester number (participant, e.g., 1) (7 for short T2)
experiment_no = 3; % Set the experiment number (session number, e.g., 2) (7-1 only haptics, 7-2 only visual, 7-3 both)

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


% Call your main experiment function for each variant (replace with your own logic)
% Example: running the experiment for variant 1, 2, and 3
haptic = {haptic1, haptic2, haptic3}; 
visual = {visual1, visual2, visual3};
variant = {variant1, variant2, variant3};

% Initialize workload matrix with zeros (assuming 3 repetitions)
workload = zeros(1, length(haptic));

for i = 1:length(haptic)
    
    PrvniCastVisual(tester, experiment_no, haptic{i}, visual{i}, i, testcase, saveFolder);
    DruhaCastVisual(tester, experiment_no, haptic{i}, visual{i}, i, testcase, variant{i}, saveFolder);
        workload(i) = input(sprintf('Please enter a number for workload (Repetition %d): ', i));
end

% Create a table with headers
repetitions = 1:length(haptic); % Column headers (1,2,3,...)
T = array2table(workload, 'VariableNames', strcat("Repetition_", string(repetitions)));

% Define CSV file name
csvFileName = fullfile(saveFolder, 'workload.csv');

% Save the table to CSV
writetable(T, csvFileName);

disp(['Workload matrix saved to ', csvFileName]);

% Optionally, save results or generate reports after the experiment
disp('Experiment completed.');
