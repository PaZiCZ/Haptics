function ValidateXlsx(files)
    % This function checks that Temperature and Altitude files exist.
    % It also checks if Temperature and Altitude files exist in LabVIEW Data folder
    % And it also evaluates all Excel files generated during the experiment to ensure there are no errors in the data.
    
    % Required files
    requiredFiles = {"Temperature.xlsx", "Altitude.xlsx"};
    existingFiles = {files.name};
    
    % Check if required files exist
    for i = 1:length(requiredFiles)
        if ~any(strcmp(requiredFiles{i}, existingFiles))
            disp(['Error: Missing required file: ', requiredFiles{i}]);
            return;
        end
    end

    % Check if Temperature and Altitude files exist in LabVIEW Data folder
    checkLabVIEWDataFolder();

    % Initialize a flag to detect errors
    hasErrors = false;
    
    % Loop through each file
    for i=1:length(files)
        file = files(i);
        [hasErrors, data] = readXlsx(file);
        if hasErrors
            break;
        end
        
        hasErrors = validateXlsxCells(data, file);
        if hasErrors
            break;
        end
    end
    
    % Display the evaluation result
    if hasErrors
        disp('There are errors in the data. The experiment should be repeated.');
    else
        disp('Data has been recorded and saved correctly.');
    end
end
 
function [hasErrors, data] = readXlsx(file) 
    hasErrors = false;
    data=[];
    try
        data = readtable(fullfile(file.folder, file.name));
    catch
        disp(['Error reading file: ', file.name]);
        hasErrors = true;
    end
end

function hasErrors = validateXlsxCells(data, file)
    hasErrors=false;
    for row = 1:size(data, 1)
        for col = 1:size(data, 2)
            cellValue = data{row, col};
            
            % Check if the value is not numeric or is NaN
            if ~isnumeric(cellValue) || isnan(cellValue)
                % If it's not numeric, check if it's a valid date and time
                try
                    % Try to convert the value to a date-time serial number
                    datetime(cellValue, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
                catch
                    % If the conversion fails, mark it as an error
                    disp(['Error in file: ', file, ' at row ', num2str(row), ', column ', num2str(col)]);
                    hasErrors = true;
                    return;
                end
            end
        end
    end
end

function checkLabVIEWDataFolder()
    labviewFolder = "C:\\Users\\simulator\\Documents\\LabVIEW Data";
    filesToCheck = {"Temperature.xlsx", "Altitude.xlsx"};
    
    for i = 1:length(filesToCheck)
        filePath = fullfile(labviewFolder, filesToCheck{i});
        if exist(filePath, 'file')
            disp(['Warning: ', filesToCheck{i}, ' is still in ', labviewFolder, '. Please delete it.']);
        end
    end
end