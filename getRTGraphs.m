% Function to plot RT data for Task 1 for each volunteer
function getRTGraphs(postProcessingFolder)

    % Create a new folder inside postProcessingFolder for saving PNGs
    volunteerFolder = fullfile(postProcessingFolder, 'volunteerTRTPperSession');
    if ~exist(volunteerFolder, 'dir')
        mkdir(volunteerFolder);  % Create the folder if it does not exist
    end

    % List of volunteers (1 to 12)
    volunteers = 1:12;

    % Initialize a cell array to hold RT values for each session and
    % feedback type for task 1
    allHapticRT1 = NaN(length(volunteers), 5); % Only 5 first sessions
    allVisualRT1 = NaN(length(volunteers), 5);
    allHapticVisualRT1 = NaN(length(volunteers), 5);

    meanHapticRT1 = NaN(1, 5);
    meanVisualRT1 = NaN(1, 5);
    meanHapticVisualRT1 = NaN(1, 5);

    % Loop through each volunteer
    for volunteer = volunteers
        % Load the combined RT data for Task 1 from the saved files
        task1DataPath = fullfile(postProcessingFolder, 'completeDataforTask1', sprintf('Volunteer_%d_DataforTask1_combined.xlsx', volunteer));

        % Read the data
        task1Data = readtable(task1DataPath);

        % Prepare session numbers (1-5, and 7-8)
        sessionstest = [1, 2, 3, 4, 5];
        sessions = [1, 2, 3, 4, 5, 7, 8];
        
        % Create a figure for Task 1 RT data
        figure;

        % Plot Task 1 RT data
        hold on;
        
        % Loop through each row in task1Data and classify based on GuidanceMethod and ParallelTask
        for i = 1:height(task1Data)
            session = task1Data.Session(i);  % Session number from the Session column
            RT_value = task1Data.RT_s_(i);  % RT value for this row
            guidanceMethod = task1Data.GuidanceMethod{i};  % Get the GuidanceMethod for the current row
            parallelTask = task1Data.ParallelTask(i);  % Get the ParallelTask value for the current row

            % Determine the marker and color based on GuidanceMethod and ParallelTask
            if strcmp(guidanceMethod, 'Haptic')
                marker = 's';  % Square for Haptic
                if session<=5
                    allHapticRT1(volunteer,session) = RT_value;
                end
            elseif strcmp(guidanceMethod, 'Visual')
                marker = 'o';  % Circle for Visual
                if session<=5
                    allVisualRT1(volunteer,session) = RT_value;
                end
            elseif strcmp(guidanceMethod, 'Haptic + Visual')
                marker = '^';  % Triangle for Haptic + Visual
                if session<=5
                    allHapticVisualRT1(volunteer,session) = RT_value;
                end
            end
            
            % Set the color based on ParallelTask (1 for green, 0 for blue)
            if parallelTask == 1
                color = [0.6, 0.8, 0.2];  % Green for Parallel Task
            else
                color = [0.4, 0.6, 0.8];  % Blue for Non-Parallel Task
            end

            % Plot the point with the corresponding X, Y, marker, and color
            scatter(session, RT_value, 100, 'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor', [0.3, 0.3, 0.3]);
        end

        % Add labels and title for Task 1
        title(['Time to Reach Target Position of Volunteer ', num2str(volunteer), ' for Task 1'], 'FontSize', 14, ...
              'Position', [mean(sessions), max(task1Data.RT_s_)*1.1, 0]);
        xlabel('\bfSession', 'FontSize', 12);
        ylabel('\bfTRTP (s)', 'FontSize', 12);
        xticks(sessions);  % Use sessions as the x-axis ticks
        xticklabels(sessions);  % Label each tick with the session number
        % xlim([min(sessions), max(sessions)]);
        % ylim([min(task1Data.RT_s_)-min(task1Data.RT_s_)*0.1, max(task1Data.RT_s_) * 1.1]);
        % Set X and Y limits to start from 0
        xlim([min(sessions)-min(sessions)*0.5, max(sessions)+min(sessions)*0.5]);
        ylim([min(task1Data.RT_s_)-min(task1Data.RT_s_)*0.1, max(task1Data.RT_s_) * 1.1]);


        line([5.75 5.75], [0 max(task1Data.RT_s_)*1.1], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
        line([6.25 6.25], [0 max(task1Data.RT_s_)*1.1], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);

        % Create the grid of vertical and horizontal lines between session 5.75 and 6.25
        % Vertical lines
        for x = 5.80:0.05:6.20  % Vertical lines from 5.75 to 6.25
            line([x, x], [0, max(task1Data.RT_s_)*1.1], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end

        % Horizontal lines
        for y = 0:0.05:max(task1Data.RT_s_)*1.1  % Horizontal lines from Y = 0 to max(RT)
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
        saveas(gcf, fullfile(volunteerFolder, sprintf('Volunteer_%d_TRTP_Charts.png', volunteer)));

        % Save the same plot as a MATLAB .fig file in the same folder
        savefig(gcf, fullfile(volunteerFolder, sprintf('Volunteer_%d_TRTP_Charts.fig', volunteer)));
    end

    for i = 1:5
        meanHapticRT1(1, i) = mean(allHapticRT1(:, i), 'omitnan');
        meanVisualRT1(1, i) = mean(allVisualRT1(:, i), 'omitnan'); 
        meanHapticVisualRT1(1, i) = mean(allHapticVisualRT1(:, i), 'omitnan');        
    end

    % Create the final plot with the average RT across all volunteers for Task 1
    figure;
    
    % Plot the average RT values for all volunteers for Task 1
    hold on;
    plot(sessionstest, meanHapticRT1, '-o', 'DisplayName', 'Haptic', 'LineWidth', 2);
    plot(sessionstest, meanVisualRT1, '-x', 'DisplayName', 'Visual', 'LineWidth', 2);
    plot(sessionstest, meanHapticVisualRT1, '-^', 'DisplayName', 'Haptic + Visual', 'LineWidth', 2);

    % Add labels and title
    title('Time to Reach Target Position for All Volunteers - Task 1', 'FontSize', 14);
    xlabel('\bfSession', 'FontSize', 12);
    ylabel('\bfTRTP (s)', 'FontSize', 12);
    xticks(sessionstest);  % Use sessions as the x-axis ticks
    xticklabels(sessionstest);  % Label each tick with the session number
    xlim([min(sessionstest)-min(sessionstest)*0.5, max(sessionstest)+min(sessionstest)*0.5]);
    ylim([min([meanHapticRT1, meanVisualRT1, meanHapticVisualRT1]) - min([meanHapticRT1, meanVisualRT1, meanHapticVisualRT1]) * 0.1, max([meanHapticRT1, meanVisualRT1, meanHapticVisualRT1]) + min([meanHapticRT1, meanVisualRT1, meanHapticVisualRT1]) * 0.1]);

    % Add grid and legend
    grid on;
    legend('show');

    % Save the average plot for all volunteers
    saveas(gcf, fullfile(postProcessingFolder, 'Average_RT_Charts_Task1.png'));
    savefig(gcf, fullfile(postProcessingFolder, 'Average_RT_Charts_Task1.fig'));
end