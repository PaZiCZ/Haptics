% Define the path where the data folders are located
saveFolder = fullfile("C:\Users\Jan\Desktop\measurement");  % Replace with correct path

% Create the 'Post-processing data' folder within saveFolder
postProcessingFolder = fullfile(saveFolder, 'Post-processing data');
if ~exist(postProcessingFolder, 'dir')
    mkdir(postProcessingFolder);  % Create folder if it doesn't exist
    disp(['Created folder for post-processing data: ', postProcessingFolder]);
end

% Call the functions to process the data and save them in the new folder
createDataTables(saveFolder, postProcessingFolder);
createDataTables_7_8(saveFolder, postProcessingFolder);
completeDataTables(postProcessingFolder);
getAEGraphs(postProcessingFolder)
getRTGraphs(postProcessingFolder)
getWorkloadGraphs(postProcessingFolder);
getIDGraphs(saveFolder, postProcessingFolder)
close all;
