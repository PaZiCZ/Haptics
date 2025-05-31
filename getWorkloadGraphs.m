% Function to plot Workload data for Task 1 and Task 2 for each volunteer
function getWorkloadGraphs(postProcessingFolder)
    % Create folder to save PNG and FIG results
    volunteerFolder = fullfile(postProcessingFolder, 'volunteerWorkloadPerSession');
    if ~exist(volunteerFolder, 'dir')
        mkdir(volunteerFolder);
    end

    volunteers = 1:12;
    
    % Preallocate arrays for means
    meanHapticWL1 = NaN(1, 5);
    meanVisualWL1 = NaN(1, 5);
    meanHapticVisualWL1 = NaN(1, 5);
    
    meanHapticWL2 = NaN(1, 5);
    meanVisualWL2 = NaN(1, 5);
    meanHapticVisualWL2 = NaN(1, 5);

    allHapticWL1 = NaN(length(volunteers), 5);
    allVisualWL1 = NaN(length(volunteers), 5);
    allHapticVisualWL1 = NaN(length(volunteers), 5);
    
    allHapticWL2 = NaN(length(volunteers), 5);
    allVisualWL2 = NaN(length(volunteers), 5);
    allHapticVisualWL2 = NaN(length(volunteers), 5);

    for volunteer = volunteers
        task1DataPath = fullfile(postProcessingFolder, 'completeDataforTask1', sprintf('Volunteer_%d_DataforTask1_combined.xlsx', volunteer));
        task2DataPath = fullfile(postProcessingFolder, 'completeDataforTask2', sprintf('Volunteer_%d_DataforTask2_combined.xlsx', volunteer));

        task1Data = readtable(task1DataPath);
        task2Data = readtable(task2DataPath);

        % Prepare session numbers (1-5, and 7-8)
        sessionstest = [1, 2, 3, 4, 5];
        sessions = [1, 2, 3, 4, 5, 7, 8];

        figure;

        %% Task 1
        subplot(2,1,1);
        hold on;
        for i = 1:height(task1Data)
            session = task1Data.Session(i);
            value = task1Data.Workload(i);
            guidance = task1Data.GuidanceMethod{i};
            parallel = task1Data.ParallelTask(i);

            if strcmp(guidance, 'Haptic')
                marker = 's';
                if session <= 5
                    allHapticWL1(volunteer, session) = value;
                end
            elseif strcmp(guidance, 'Visual')
                marker = 'o';
                if session <= 5
                    allVisualWL1(volunteer, session) = value;
                end
            elseif strcmp(guidance, 'Haptic + Visual')
                marker = '^';
                if session <= 5
                    allHapticVisualWL1(volunteer, session) = value;
                end
            end

            if parallel == 1
                color = [0.6, 0.8, 0.2];
            else
                color = [0.4, 0.6, 0.8];
            end

            scatter(session, value, 100, 'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor', [0.3, 0.3, 0.3]);
        end

        % Add labels and title for Task 1
        title(['Workload of Volunteer ', num2str(volunteer), ' for Task 1'], 'FontSize', 14, ...
              'Position', [mean(sessions), max(task1Data.Workload)*1.5, 0]);
        xlabel('\bfSession', 'FontSize', 12);
        ylabel('\bfWorkload', 'FontSize', 12);
        xticks(sessions);  % Use sessions as the x-axis ticks
        xticklabels(sessions);  % Label each tick with the session number
        
        % Set X and Y limits to start from 0
        xlim([0, max(sessions) + 1]);  % Add a small margin after session 8
        ylim([0, max(task1Data.Workload) * 1.5]);  % Add some space above the highest Workload value


        line([5.75 5.75], [0 max(task1Data.Workload)*1.5], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
        line([6.25 6.25], [0 max(task1Data.Workload)*1.5], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);

        % Create the grid of vertical and horizontal lines between session 5.75 and 6.25
        % Vertical lines
        for x = 5.80:0.05:6.20  % Vertical lines from 5.75 to 6.25
            line([x, x], [0, max(task1Data.Workload)*1.5], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end

        % Horizontal lines
        for y = 0:0.1:max(task1Data.Workload)*1.5  % Horizontal lines from Y = 0 to max(Workload)
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

        %% Task 2
        subplot(2,1,2);
        hold on;
        for i = 1:height(task2Data)
            session = task2Data.Session(i);
            value = task2Data.Workload(i);
            guidance = task2Data.GuidanceMethod{i};
            parallel = task2Data.ParallelTask(i);

            if strcmp(guidance, 'Haptic')
                marker = 's';
                if session <= 5
                    allHapticWL2(volunteer, session) = value;
                end
            elseif strcmp(guidance, 'Visual')
                marker = 'o';
                if session <= 5
                    allVisualWL2(volunteer, session) = value;
                end
            elseif strcmp(guidance, 'Haptic + Visual')
                marker = '^';
                if session <= 5
                    allHapticVisualWL2(volunteer, session) = value;
                end
            end

            if parallel == 1
                color = [0.6, 0.8, 0.2];
            else
                color = [0.4, 0.6, 0.8];
            end

            scatter(session, value, 100, 'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor', [0.3, 0.3, 0.3]);
        end

        % Add labels and title for Task 2
        title(['Workload of Volunteer ', num2str(volunteer), ' for Task 2'], 'FontSize', 14, ...
              'Position', [mean(sessions), max(task2Data.Workload)*1.5, 0]);
        xlabel('\bfSession', 'FontSize', 12);
        ylabel('\bfWorkload', 'FontSize', 12);
        xticks(sessions);  % Use sessions as the x-axis ticks
        xticklabels(sessions);  % Label each tick with the session number
        
        % Set X and Y limits to start from 0
        xlim([0, max(sessions) + 1]);  % Add a small margin after session 8
        ylim([0, max(task2Data.Workload) * 1.5]);  % Add some space above the highest Workload value


        line([5.75 5.75], [0 max(task2Data.Workload)*1.5], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
        line([6.25 6.25], [0 max(task2Data.Workload)*1.5], 'LineStyle', '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);

        % Create the grid of vertical and horizontal lines between session 5.75 and 6.25
        % Vertical lines
        for x = 5.80:0.05:6.20  % Vertical lines from 5.75 to 6.25
            line([x, x], [0, max(task2Data.Workload)*1.5], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
        end

        % Horizontal lines
        for y = 0:0.1:max(task2Data.Workload)*1.5  % Horizontal lines from Y = 0 to max(Workload)
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


        % Save plots
        saveas(gcf, fullfile(volunteerFolder, sprintf('Volunteer_%d_Workload_Charts.png', volunteer)));
        savefig(gcf, fullfile(volunteerFolder, sprintf('Volunteer_%d_Workload_Charts.fig', volunteer)));
    end

    for i = 1:5
        meanHapticWL1(i) = mean(allHapticWL1(:, i), 'omitnan');
        meanVisualWL1(i) = mean(allVisualWL1(:, i), 'omitnan');
        meanHapticVisualWL1(i) = mean(allHapticVisualWL1(:, i), 'omitnan');

        meanHapticWL2(i) = mean(allHapticWL2(:, i), 'omitnan');
        meanVisualWL2(i) = mean(allVisualWL2(:, i), 'omitnan');
        meanHapticVisualWL2(i) = mean(allHapticVisualWL2(:, i), 'omitnan');
    end

    figure;

    subplot(2,1,1);
    hold on;
    plot(sessionstest, meanHapticWL1, '-o', 'DisplayName', 'Haptic', 'LineWidth', 2);
    plot(sessionstest, meanVisualWL1, '-x', 'DisplayName', 'Visual', 'LineWidth', 2);
    plot(sessionstest, meanHapticVisualWL1, '-^', 'DisplayName', 'Haptic + Visual', 'LineWidth', 2);
    
    title('Average Workload for all Volunteers - Task 1', 'FontSize', 14);
    xlabel('\bfSession', 'FontSize', 12);
    ylabel('\bfWorkload', 'FontSize', 12);
    xticks(sessionstest);  % Use sessions as the x-axis ticks
    xticklabels(sessionstest);  % Label each tick with the session number
    xlim([min(sessionstest)-min(sessionstest)*0.5, max(sessionstest)+min(sessionstest)*0.5]);
    ylim([0, max([meanHapticWL1, meanVisualWL1, meanHapticVisualWL1])*1.25]);

    % Add grid and legend
    grid on;
    legend('show');

    % Plot the average Workload values for all volunteers for Task 2
    subplot(2,1,2);
    hold on;
    plot(sessionstest, meanHapticWL2, '-o', 'DisplayName', 'Haptic', 'LineWidth', 2);
    plot(sessionstest, meanVisualWL2, '-x', 'DisplayName', 'Visual', 'LineWidth', 2);
    plot(sessionstest, meanHapticVisualWL2, '-^', 'DisplayName', 'Haptic + Visual', 'LineWidth', 2);
    
    % Add labels and title for Task 2
    title('Average Workload for All Volunteers - Task 2', 'FontSize', 14);
    xlabel('\bfSession', 'FontSize', 12);
    ylabel('\bfWorkload', 'FontSize', 12);
    xticks(sessionstest);  % Use sessions as the x-axis ticks
    xticklabels(sessionstest);  % Label each tick with the session number
    xlim([min(sessionstest)-min(sessionstest)*0.5, max(sessionstest)+min(sessionstest)*0.5]);
    ylim([0, max([meanHapticWL2, meanVisualWL2, meanHapticVisualWL2])*1.25]);

    % Add grid and legend
    grid on;
    legend('show');

    saveas(gcf, fullfile(postProcessingFolder, 'Average_Workload_Charts_Task1_and_Task2.png'));
    savefig(gcf, fullfile(postProcessingFolder, 'Average_Workload_Charts_Task1_and_Task2.fig'));
end