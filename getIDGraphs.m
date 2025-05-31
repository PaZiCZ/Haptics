% Function to plot ID_difficulty vs RT for Task 1 for each volunteer
function getIDGraphs(saveFolder, postProcessingFolder)

    % Create a new folder inside postProcessingFolder for saving PNGs
    volunteerFolder = fullfile(postProcessingFolder, 'volunteerIDGraphs');
    if ~exist(volunteerFolder, 'dir')
        mkdir(volunteerFolder);  % Create the folder if it does not exist
    end
    
    toleranceX = 0.1; % tolerance to define target position interval (only Task 1)

    % List of volunteers (1 to 12)
    volunteers = 1:12;
    sessions = [1, 2, 3, 4, 5, 7, 8]; % Available sessions

    % To store the regressions lines of each volunteer
    regression_lines_Haptic = cell(length(volunteers), 7);       % 7 sessions
    regression_lines_Visual = cell(length(volunteers), 7);
    regression_lines_HapticVisual = cell(length(volunteers), 7);


    % Loop through each volunteer
    for volunteer = volunteers
        for session = sessions

            % Define the folder path for the session and volunteer
            folderName = sprintf('te%dno%d', volunteer, session);
            csvFilesTask1 = dir(fullfile(saveFolder, folderName, 'resultsa*.csv'));
            
            % Initialize cell arrays to store ID_difficulty and RT values for each session
            ID = cell(3, 1);
            RT = cell(3, 1);
            
            % Loop through each file for Task 1 (resultsa*.csv)
            for i = 1:length(csvFilesTask1)
                % Read the data from the CSV file
                data = readtable(fullfile(csvFilesTask1(i).folder, csvFilesTask1(i).name));
                
                % Check if the column 'ID_difficulty' exists
                if ~ismember('ID_difficulty', data.Properties.VariableNames)
                    ID_valid = log2(2*data.path_V_/toleranceX); % Calculate ID
                    RT_valid = data.RTs_s_;  % Get the RT values
                else
                    % Extract ID_difficulty and RT values, and remove NaNs
                    ID_valid = data.ID_difficulty;  % Get the ID_difficulty values
                    RT_valid = data.RTs_s_;  % Get the RT values
                end
                % Remove NaN values and store valid entries
                valid_idx = ~isnan(ID_valid) & ~isnan(RT_valid);  % Identify non-NaN values
                ID{i} = ID_valid(valid_idx);  % Store the valid ID_difficulty values
                RT{i} = RT_valid(valid_idx);  % Store the valid RT values
            end

            csvFiles2Task1 = dir(fullfile(saveFolder, folderName, 'resultsd*.csv'));

            % Initialize cell arrays to store intersection point (of Y axis), slope and RMSE
            Intersection = cell(3, 1);  
            Slope = cell(3, 1);  
            RMSE = cell(3, 1);  

            % Loop through each file for Task 1 (resultsd*.csv)
            for i = 1:length(csvFiles2Task1)
                % Read the data from the CSV file
                data = readtable(fullfile(csvFiles2Task1(i).folder, csvFiles2Task1(i).name));
                
                if ~ismember('intersection_withMTAxis_', data.Properties.VariableNames)
                    p = polyfit(ID{i}, RT{i}, 1); % p(1) is the slope, p(2) is the intercept
                    y_fit = polyval(p, ID{i}); % Fitted values
                    
                    % Calculate Root Mean Squared Error (RMSE)
                    residuals = RT{i} - y_fit;  
                    Intersection{i} = p(2);
                    Slope{i} = p(1);
                    RMSE{i} = sqrt(mean(residuals.^2));
                else
                    if isnan(data.intersection_withMTAxis_) || isnan(data.slope) || isnan(data.accuracy)
                        p = polyfit(ID{i}, RT{i}, 1); % p(1) is the slope, p(2) is the intercept
                        y_fit = polyval(p, ID{i}); % Fitted values
                        
                        % Calculate Root Mean Squared Error (RMSE)
                        residuals = RT{i} - y_fit;  
                        Intersection{i} = p(2);
                        Slope{i} = p(1);
                        RMSE{i} = sqrt(mean(residuals.^2));
                    else                    
                        Intersection{i} = data.intersection_withMTAxis_;
                        Slope{i} = data.slope; 
                        RMSE{i} = data.accuracy;
                    end
                end
            end

            % Load the combined data for Task 1 (Volunteer_%d_DataforTask1_combined.xlsx)
            task1DataPath = fullfile(postProcessingFolder, 'completeDataforTask1', sprintf('Volunteer_%d_DataforTask1_combined.xlsx', volunteer));
            task1Data = readtable(task1DataPath);
    
            % Create the figure for each session (1 to 8)
            for i = 1:3

                if session<=5
                    guidanceMethod = task1Data.GuidanceMethod{(session-1)*3 + i};  % Get the GuidanceMethod for the current row
                    parallelTask = task1Data.ParallelTask((session-1)*3 + i);  % Get the ParallelTask value for the current row
                else
                    guidanceMethod = task1Data.GuidanceMethod{(session-2)*3 + i};  % Get the GuidanceMethod for the current row
                    parallelTask = task1Data.ParallelTask((session-2)*3 + i);  % Get the ParallelTask value for the current row
                end

                if parallelTask == 1
                    parallelTask = 'Parallel Task';
                else
                    parallelTask = 'Non-Parallel Task';
                end

                regression_data = struct();
                regression_data.ID = ID{i};
                regression_data.y_fit = polyval([Slope{i}, Intersection{i}], ID{i});
                regression_data.session = session;
                
                switch guidanceMethod 
                    case 'Haptic'
                        regression_lines_Haptic{volunteer, session} = regression_data;
                    case 'Visual'
                        regression_lines_Visual{volunteer, session} = regression_data;
                    case 'Haptic + Visual'
                        regression_lines_HapticVisual{volunteer, session} = regression_data;
                end
    
                % Create a subplot for the current experiment
                subplot(3,1,i);  % 3 subplots for each session
                scatter(ID{i,1}, RT{i,1}, 'b', 'filled'); % Points of MT vs ID_difficulty
                hold on;
    
                % Plot the regression line for the current experiment
                plot(ID{i}, polyval([Slope{i}, Intersection{i}], ID{i}), 'r-', 'LineWidth', 2);
    
                % Title based on guidance method and parallel task
                titleText = sprintf('MT vs ID\\_difficulty  of Tester %d in sesion %d in %s conditions with %s', volunteer, session, guidanceMethod, parallelTask);
                title(titleText, 'FontSize', 12);
                xlabel('ID\_difficulty', 'FontSize', 12, 'FontWeight', 'bold');
                ylabel('MT (s)', 'FontSize', 12, 'FontWeight', 'bold');
                legendInfo = sprintf('Intersection point: \\bf%.2f\\rm\nSlope of regression line: \\bf%.2f\\rm\nRMSE: \\bf%.4f\\rm', Intersection{i}, Slope{i}, RMSE{i});
                legend('Data', 'Regression Line', 'Location', 'northwest', 'TextColor', 'black', 'String', legendInfo);
                grid on;
                hold off;
            end
    
            % Save the plot as a .fig and .png file
            File_2 = sprintf('Volunteer_%d_Session%d_MT_vs_ID.fig', volunteer, session);
            saveas(gcf, fullfile(volunteerFolder, File_2));  % Save the figure

            % Save as PNG
            File_2_PNG = sprintf('Volunteer_%d_Session%d_MT_vs_ID.png', volunteer, session);
            saveas(gcf, fullfile(volunteerFolder, File_2_PNG));  % Save the PNG
        end
        guidanceMethods = {'Haptic', 'Visual', 'Haptic + Visual'};
        colors = lines(8);  % Hasta 7 sesiones

        for g = 1:length(guidanceMethods)
            figure; hold on; grid on;
            legendEntries = {};
            for session = sessions
                switch guidanceMethods{g}
                    case 'Haptic'
                        lineData = regression_lines_Haptic{volunteer, session};
                    case 'Visual'
                        lineData = regression_lines_Visual{volunteer, session};
                    case 'Haptic + Visual'
                        lineData = regression_lines_HapticVisual{volunteer, session};
                end
                if ~isempty(lineData)
                    plot(lineData.ID, lineData.y_fit, 'LineWidth', 2, 'Color', colors(session,:));
                    legendEntries{end+1} = sprintf('Session %d', session);
                end
            end
            % Set title and axis labels with formatting
            title(sprintf('Volunteer %d - %s (All Sessions)', volunteer, guidanceMethods{g}), 'FontSize', 14);
            xlabel('ID\_difficulty', 'FontWeight', 'bold');
            ylabel('MT (s)', 'FontWeight', 'bold');
            legend(legendEntries, 'Location', 'northwest');

            % Save figure
            fileNameFig = sprintf('Volunteer_%d_%s_AllSessions.fig', volunteer, strrep(guidanceMethods{g}, ' ', ''));
            fileNamePng = sprintf('Volunteer_%d_%s_AllSessions.png', volunteer, strrep(guidanceMethods{g}, ' ', ''));
            saveas(gcf, fullfile(volunteerFolder, fileNameFig));
            saveas(gcf, fullfile(volunteerFolder, fileNamePng));
            close;
        end
    end
    % ------ NEW: PLOT AVERAGE REGRESSION LINES FOR ALL VOLUNTEERS BY GUIDANCE ------ %
    guidanceMethods = {'Haptic', 'Visual', 'Haptic + Visual'};
    sessionColors = [
        0.0, 0.447, 0.741;   % Session 1 (blue)
        0.85, 0.325, 0.098;  % Session 2 (orange)
        0.929, 0.694, 0.125; % Session 3 (yellow)
        0.494, 0.184, 0.556; % Session 4 (purple)
        0.466, 0.674, 0.188; % Session 5 (green)
        0.301, 0.745, 0.933; % Session 7 (cyan)
        0.635, 0.078, 0.184  % Session 8 (red)
    ];
    sessions = [1,2,3,4,5,7,8];
    
    for g = 1:length(guidanceMethods)
        figure; hold on; grid on;
        legendEntries = {};
        for sIdx = 1:length(sessions)
            session = sessions(sIdx);
            all_IDs = [];
            all_Yfit = [];
            for volunteer = volunteers
                switch guidanceMethods{g}
                    case 'Haptic'
                        lineData = regression_lines_Haptic{volunteer, session};
                    case 'Visual'
                        lineData = regression_lines_Visual{volunteer, session};
                    case 'Haptic + Visual'
                        lineData = regression_lines_HapticVisual{volunteer, session};
                end
                if ~isempty(lineData)
                    all_IDs = [all_IDs; lineData.ID(:)];
                    all_Yfit = [all_Yfit; lineData.y_fit(:)];
                end
            end
            [sortedIDs, sortIdx] = sort(all_IDs);
            sortedYfit = all_Yfit(sortIdx);
            if ~isempty(sortedIDs)
                p = polyfit(sortedIDs, sortedYfit, 1);
                x_line = linspace(min(sortedIDs), max(sortedIDs), 100);
                y_line = polyval(p, x_line);
                plot(x_line, y_line, 'LineWidth', 2, 'Color', sessionColors(sIdx,:));
                legendEntries{end+1} = sprintf('Session %d', session);
            end
        end
        title(sprintf('MT vs ID (All Volunteers) - %s', guidanceMethods{g}), 'FontSize', 14);
        xlabel('Index of Difficulty', 'FontWeight', 'bold');
        ylabel('Movement Time (s)', 'FontWeight', 'bold');
        legend(legendEntries, 'Location', 'northwest');
        outName = sprintf('AllVolunteers_%s_AllSessions', strrep(guidanceMethods{g}, ' ', ''));
        saveas(gcf, fullfile(postProcessingFolder, [outName '.fig']));
        saveas(gcf, fullfile(postProcessingFolder, [outName '.png']));
        close;
    end
end