% Function to plot AE data for Task 1 and Task 2 for each volunteer
function getAEGraphs(postProcessingFolder)

    % Create a new folder inside postProcessingFolder for saving PNGs
    volunteerFolder = fullfile(postProcessingFolder, 'volunteerAEperSession');
    if ~exist(volunteerFolder, 'dir')
        mkdir(volunteerFolder);  % Create the folder if it does not exist
    end

    % List of volunteers (1 to 12)
    volunteers = 1:12;

    % Initialize a cell array to hold AE values for each session and
    % feedback type for task 1
    allHapticAE1 = NaN(length(volunteers), 5); % Only 5 first sessions
    allVisualAE1 = NaN(length(volunteers), 5);
    allHapticVisualAE1 = NaN(length(volunteers), 5);

    % Initialize a cell array to hold AE values for each session and
    % feedback type for task 2
    allHapticAE2 = NaN(length(volunteers), 5); % Only 5 first sessions
    allVisualAE2 = NaN(length(volunteers), 5);
    allHapticVisualAE2 = NaN(length(volunteers), 5);


    meanHapticAE1 = NaN(1, 5);
    meanVisualAE1 = NaN(1, 5);
    meanHapticVisualAE1 = NaN(1, 5);

    meanHapticAE2 = NaN(1, 5);
    meanVisualAE2 = NaN(1, 5);
    meanHapticVisualAE2 = NaN(1, 5);

    % Loop through each volunteer
    for volunteer = volunteers
        % Load the combined AE data for Task 1 and Task 2 from the saved files
        task1DataPath = fullfile(postProcessingFolder, 'completeDataforTask1', sprintf('Volunteer_%d_DataforTask1_combined.xlsx', volunteer));
        task2DataPath = fullfile(postProcessingFolder, 'completeDataforTask2', sprintf('Volunteer_%d_DataforTask2_combined.xlsx', volunteer));

        % Read the data
        task1Data = readtable(task1DataPath);
        task2Data = readtable(task2DataPath);

        % Prepare session numbers (1-5, and 7-8)
        sessionstest = [1, 2, 3, 4, 5];
        sessions = [1, 2, 3, 4, 5, 7, 8];

        % Create a figure for Task 1 and Task 2
        figure;

        % Plot Task 1 AE data
        subplot(2,1,1);  % Create a subplot (2 rows, 1 column, first plot)
        hold on;
        
        % Loop through each row in task1Data and classify based on GuidanceMethod and ParallelTask
        for i = 1:height(task1Data)
            session = task1Data.Session(i);  % Session number from the Session column
            AE_value = task1Data.AE(i);  % AE value for this row
            guidanceMethod = task1Data.GuidanceMethod{i};  % Get the GuidanceMethod for the current row
            parallelTask = task1Data.ParallelTask(i);  % Get the ParallelTask value for the current row

            % Determine the marker and color based on GuidanceMethod and ParallelTask
            if strcmp(guidanceMethod, 'Haptic')
                marker = 's';  % Square for Haptic
                if session<=5
                    allHapticAE1(volunteer,session) = AE_value;
                end
            elseif strcmp(guidanceMethod, 'Visual')
                marker = 'o';  % Circle for Visual
                if session<=5
                    allVisualAE1(volunteer,session) = AE_value;
                end
            elseif strcmp(guidanceMethod, 'Haptic + Visual')
                marker = '^';  % Triangle for Haptic + Visual
                if session<=5
                    allHapticVisualAE1(volunteer,session) = AE_value;
                end
            end
            
            % Set the color based on ParallelTask (1 for green, 0 for blue)
            if parallelTask == 1
                color = [0.6, 0.8, 0.2];  % Green for Parallel Task
            else
                color = [0.4, 0.6, 0.8];  % Blue for Non-Parallel Task
            end

            % Plot the point with the corresponding X, Y, marker, and color
            scatter(session, AE_value, 100, 'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor', [0.3, 0.3, 0.3]);
        end

        % Add labels and title for Task 1
        title(['Average Error of Volunteer ', num2str(volunteer), ' for Task 1'], 'FontSize', 14, ...
              'Position', [mean(sessions), max(task1Data.AE)*1.1, 0]);
        xlabel('\bfSession', 'FontSize', 12);
        ylabel('\bfAverage Error (AE)', 'FontSize', 12);
        xticks(sessions);  % Use sessions as the x-axis ticks
        xticklabels(sessions);  % Label each tick with the session number
        
        % Set X and Y limits to start from 0
        xlim([0, max(sessions) + 1]);  % Add a small margin after session 8
        ylim([0, max(task1Data.AE) * 1.1]);  % Add some space above the highest AE value


        line([5.75 5.75], [0 max(task1Data.AE)*1.1], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
        line([6.25 6.25], [0 max(task1Data.AE)*1.1], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);

        % Create the grid of vertical and horizontal lines between session 5.75 and 6.25
        % Vertical lines
        for x = 5.80:0.05:6.20  % Vertical lines from 5.75 to 6.25
            line([x, x], [0, max(task1Data.AE)*1.1], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end

        % Horizontal lines
        for y = 0:0.005:max(task1Data.AE)*1.1  % Horizontal lines from Y = 0 to max(AE)
            line([5.75, 6.25], [y, y], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end

        % Create custom legend with two columns
        % First column: Shapes (square, circle, triangle)
        % Second column: Colors (green for parallel, blue for non-parallel)

        % Draw invisible plot handles to represent shapes
        h1 = plot(NaN, NaN, 's', 'MarkerEdgeColor', 'k');  % Haptic (Square)
        h2 = plot(NaN, NaN, 'o', 'MarkerEdgeColor', 'k');  % Visual (Circle)
        h3 = plot(NaN, NaN, '^', 'MarkerEdgeColor', 'k');  % Haptic + Visual (Triangle)
        
        % Create a diamond shape for Parallel Task (green)
        h4 = plot(NaN, NaN, 'd', 'MarkerFaceColor', [0.6, 0.8, 0.2], 'MarkerEdgeColor', 'k');  % Parallel Task (Green Diamond)
        
        % Create a blue diamond for Non-Parallel Task
        h5 = plot(NaN, NaN, 'd', 'MarkerFaceColor', [0.4, 0.6, 0.8], 'MarkerEdgeColor', 'k');  % Non-Parallel Task (Blue Square)

        % Custom legend with two columns
        legend([h1, h2, h3, h4, h5], ...
               {'Haptic (Square)', 'Visual (Circle)', 'Haptic + Visual (Triangle)', ...
                'Parallel Task (Green Color)', 'Non-Parallel Task (Blue Color)'}, ...
               'Location', 'best', 'NumColumns', 2);
        hold off;
        
        % Plot Task 2 AE data
        subplot(2,1,2);  % Second plot for Task 2
        hold on;
        
        % Loop through each row in task2Data and classify based on GuidanceMethod and ParallelTask
        for i = 1:height(task2Data)
            session = task2Data.Session(i);  % Session number from the Session column
            AE_value = task2Data.AE(i);  % AE value for this row
            guidanceMethod = task2Data.GuidanceMethod{i};  % Get the GuidanceMethod for the current row
            parallelTask = task2Data.ParallelTask(i);  % Get the ParallelTask value for the current row

            % Determine the marker and color based on GuidanceMethod and ParallelTask
            if strcmp(guidanceMethod, 'Haptic')
                marker = 's';  % Square for Haptic
                if session<=5
                    allHapticAE2(volunteer,session) = AE_value;
                end
            elseif strcmp(guidanceMethod, 'Visual')
                marker = 'o';  % Circle for Visual
                if session<=5
                    allVisualAE2(volunteer,session) = AE_value;
                end
            elseif strcmp(guidanceMethod, 'Haptic + Visual')
                marker = '^';  % Triangle for Haptic + Visual
                if session<=5
                    allHapticVisualAE2(volunteer,session) = AE_value;
                end
            end
            
            % Set the color based on ParallelTask (1 for green, 0 for blue)
            if parallelTask == 1
                color = [0.6, 0.8, 0.2];  % Green for Parallel Task
            else
                color = [0.4, 0.6, 0.8];  % Blue for Non-Parallel Task
            end

            % Plot the point with the corresponding X, Y, marker, and color
            scatter(session, AE_value, 100, 'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor', [0.3, 0.3, 0.3]);
        end

        % Add labels and title for Task 2
        title(['Average Error of Volunteer ', num2str(volunteer), ' for Task 2'], 'FontSize', 14, ...
              'Position', [mean(sessions), max(task2Data.AE)*1.1, 0]);
        xlabel('\bfSession', 'FontSize', 12);
        ylabel('\bfAverage Error (AE)', 'FontSize', 12);
        xticks(sessions);  % Use sessions as the x-axis ticks
        xticklabels(sessions);  % Label each tick with the session number
        
        % Set X and Y limits to start from 0
        xlim([0, max(sessions) + 1]);  % Add a small margin after session 8
        ylim([0, max(task2Data.AE) * 1.1]);  % Add some space above the highest AE value


        line([5.75 5.75], [0 max(task2Data.AE)*1.1], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
        line([6.25 6.25], [0 max(task2Data.AE)*1.1], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);

        % Create the grid of vertical and horizontal lines between session 5.75 and 6.25
        % Vertical lines
        for x = 5.80:0.05:6.20  % Vertical lines from 5.75 to 6.25
            line([x, x], [0, max(task2Data.AE)*1.1], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end

        % Horizontal lines
        for y = 0:0.005:max(task2Data.AE)*1.1  % Horizontal lines from Y = 0 to max(AE)
            line([5.75, 6.25], [y, y], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end

        % Create custom legend with two columns
        % First column: Shapes (square, circle, triangle)
        % Second column: Colors (green for parallel, blue for non-parallel)
        
        % Draw invisible plot handles to represent shapes
        h1 = plot(NaN, NaN, 's', 'MarkerEdgeColor', 'k');  % Haptic (Square)
        h2 = plot(NaN, NaN, 'o', 'MarkerEdgeColor', 'k');  % Visual (Circle)
        h3 = plot(NaN, NaN, '^', 'MarkerEdgeColor', 'k');  % Haptic + Visual (Triangle)
        
        % Create a diamond shape for Parallel Task (green)
        h4 = plot(NaN, NaN, 'd', 'MarkerFaceColor', [0.6, 0.8, 0.2], 'MarkerEdgeColor', 'k');  % Parallel Task (Green Diamond)
        
        % Create a blue diamond for Non-Parallel Task
        h5 = plot(NaN, NaN, 'd', 'MarkerFaceColor', [0.4, 0.6, 0.8], 'MarkerEdgeColor', 'k');  % Non-Parallel Task (Blue Square)

        % Custom legend with two columns
        legend([h1, h2, h3, h4, h5], ...
               {'Haptic (Square)', 'Visual (Circle)', 'Haptic + Visual (Triangle)', ...
                'Parallel Task (Green Color)', 'Non-Parallel Task (Blue Color)'}, ...
               'Location', 'best', 'NumColumns', 2);
        hold off;

        % Save the plot as a .png image
        saveas(gcf, fullfile(volunteerFolder, sprintf('Volunteer_%d_AE_Charts.png', volunteer)));

        % Save the same plot as a MATLAB .fig file in the same folder
        savefig(gcf, fullfile(volunteerFolder, sprintf('Volunteer_%d_AE_Charts.fig', volunteer)));
    end

    for i = 1:5
        meanHapticAE1(1, i) = mean(allHapticAE1(:, i), 'omitnan');
        meanVisualAE1(1, i) = mean(allVisualAE1(:, i), 'omitnan'); 
        meanHapticVisualAE1(1, i) = mean(allHapticVisualAE1(:, i), 'omitnan');
        
        meanHapticAE2(1, i) = mean(allHapticAE2(:, i), 'omitnan');
        meanVisualAE2(1, i) = mean(allVisualAE2(:, i), 'omitnan');
        meanHapticVisualAE2(1, i) = mean(allHapticVisualAE2(:, i), 'omitnan'); 
    end

    % Create the final plot with the average AE across all volunteers for Task 1 and Task 2
    figure;
    
    % Plot the average AE values for all volunteers for Task 1 and Task 2
    subplot(2,1,1);  % Task 1 plot
    hold on;
    plot(sessionstest, meanHapticAE1, '-o', 'DisplayName', 'Haptic', 'LineWidth', 2);
    plot(sessionstest, meanVisualAE1, '-x', 'DisplayName', 'Visual', 'LineWidth', 2);
    plot(sessionstest, meanHapticVisualAE1, '-^', 'DisplayName', 'Haptic + Visual', 'LineWidth', 2);

    % Add labels and title for Task 1
    title('Average Error for All Volunteers - Task 1', 'FontSize', 14);
    xlabel('\bfSession', 'FontSize', 12);
    ylabel('\bfAverage Error (AE)', 'FontSize', 12);
    xticks(sessionstest);  % Use sessions as the x-axis ticks
    xticklabels(sessionstest);  % Label each tick with the session number
    xlim([min(sessionstest)-min(sessionstest)*0.5, max(sessionstest)+min(sessionstest)*0.5]);
    ylim([0, max([meanHapticAE1, meanVisualAE1, meanHapticVisualAE1])*1.25]);

    % Add grid and legend
    grid on;
    legend('show');

    % Plot the average AE values for all volunteers for Task 2
    subplot(2,1,2);  % Task 2 plot
    hold on;
    plot(sessionstest, meanHapticAE2, '-o', 'DisplayName', 'Haptic', 'LineWidth', 2);
    plot(sessionstest, meanVisualAE2, '-x', 'DisplayName', 'Visual', 'LineWidth', 2);
    plot(sessionstest, meanHapticVisualAE2, '-^', 'DisplayName', 'Haptic + Visual', 'LineWidth', 2);

    % Add labels and title for Task 2
    title('Average Error for All Volunteers - Task 2', 'FontSize', 14);
    xlabel('\bfSession', 'FontSize', 12);
    ylabel('\bfAverage Error (AE)', 'FontSize', 12);
    xticks(sessionstest);  % Use sessions as the x-axis ticks
    xticklabels(sessionstest);  % Label each tick with the session number
    xlim([min(sessionstest)-min(sessionstest)*0.5, max(sessionstest)+min(sessionstest)*0.5]);
    ylim([0, max([meanHapticAE2, meanVisualAE2, meanHapticVisualAE2])*1.25]);

    % Add grid and legend
    grid on;
    legend('show');

    % Save the average plot for all volunteers (Task 1 and Task 2)
    saveas(gcf, fullfile(postProcessingFolder, 'Average_AE_Charts_Task1_and_Task2.png'));
    savefig(gcf, fullfile(postProcessingFolder, 'Average_AE_Charts_Task1_and_Task2.fig'));
end