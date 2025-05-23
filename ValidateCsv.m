function ValidateCsv(files)
    % This function evaluates all CSV files generated during the experiment to ensure there are no errors in the data.
    
    % Initialize a flag to detect errors
    hasErrors = false;
    
    % Loop through each file
    for i=1:length(files)
        file = files(i);
        [hasErrors, data] = readCsv(file);
        if hasErrors
            break
        end
        
        hasErrors = validateCsvCells(data, file);
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

function [hasErrors, data] = readCsv(file) 
    hasErrors = false;
    data=[];
    try
        data = readtable(fullfile(file.folder, file.name), 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');
    catch
        disp(['Error reading file: ', file.name]);
        hasErrors = true;
    end
end

function hasErrors = validateCsvCells(data, file)
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
                    disp(['Error in file: ', file.name, ' at row ', num2str(row), ', column ', num2str(col)]);
                    hasErrors = true;
                    return;
                end
            end
        end
    end
end
