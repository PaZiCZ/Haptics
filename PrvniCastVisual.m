%Script reads joystick position in X and Y and guides a human to randomly generated position

function [done] = PrvniCastVisual(tester, experiment_no, haptic,visual, paraleltask, repetition, testcase, saveFolder)

%script identifier
% si = 'Task 1 / randomly generated target positions';

run('spec.m');

% variables from specification file
disp(['Tester: ', num2str(tester)]);
disp(['Experiment Number: ', num2str(experiment_no)]);
disp(['Haptic: ', num2str(haptic)]);
disp(['Visual: ', num2str(visual)]);
disp(['Paralel: ', num2str(paraleltask)]);

% folder="tester"+tester+"no"+experiment_no;
% testcase="te"+tester+"no"+experiment_no; 
% saveFolder = fullfile('E:\Thesis255678\measurement', testcase);
% 
% % Ensure the folder exists; create it if it doesn't
% if ~isfolder(saveFolder)
%     mkdir(saveFolder);
%     disp(['Created folder: ', saveFolder]);
% else
%     disp(['Folder already exists: ', saveFolder]);
%     disp('DO NOT CONTINUE');
% end

T0 = 3; %
% done =0;

% rozsah joysticku - bylo by dobré to ovìøit nìjakou kalibrací
p1min = -1;
p1max = 1;

if haptic == 1
    % initial servo position
    writePosition(s1, neutral+korekce);
    writePosition(s2, neutral-korekce);
end

% Definuje ID snimaneho joysticku/pedalu, obycejne se pedaly hlasi na ID 1
ID = 1;
% Definuje snimany joystick/pedaly
joystick=vrjoystick(ID);

ticstart = 1;
trial = 1;
 
ET = tic;
i = 1;
countmax=1e7;
count=0;

position(i)= axis(joystick, 2);
    z = position(i) - 0.25;
    w = position(i) + 0.25;
disp('Do not push to a sliding element during the experiment!')

% Starting sequence based on paraleltask value
if paraleltask == 0
    % Start the experiment based on joystick movement
    disp('Start the experiment by moving the joystick forward and back.');
    
    % Wait for joystick movement (forward or backward)
    while (position(i) > z ) && (position(i) < w )&& (count < countmax)  % Wait for forward or backward movement
        position(i) = axis(joystick, 2);
        count = count + 1;
    end

elseif paraleltask == 1
    % Start the experiment based on button 13 press
    disp('Start the experiment by switch red button to A and back to OFF positions.');

    % Wait for button 13 to be pressed and released
    buttonPressed = false;
    while ~buttonPressed
        buttonState = button(joystick, 13); % Read the state of button 13
        if buttonState == 1  % Button 13 is pressed
            buttonPressed = true;
            disp('Button 13 pressed. Now release it to start the experiment.');
        end
    end
    
    % Wait for button 13 to be released
    while buttonState == 1
        buttonState = button(joystick, 13); % Continuously check if the button is released
    end
end

% Countdown for experiment start
disp('Start in 3 seconds, get ready!');
for i = 1:3
    pause(1);
    fprintf('%1.0f    ', i);
end
pause(0.5);
disp('START!');
    
     % Trail begins
    pause(1);
start_time = string(datetime('now', 'Format', 'dd.MM.yyyy HH:mm:ss'));
    % Declare basic information
    o = 1;
    no = 1;
    graf=tic;
    % Begin while loop representing one trial 
    while no <= Maxno
              
        TforDP = T0 + T0*rand;% doba do další desired position
        
        % Actual position
        AP = axis(joystick, 2);  
        
        % Desired (target) position - randomly generated
        
        DP = (p1max-p1min).*rand(1) + p1min;  
        while DP+2*toleranceX>AP && DP-2*toleranceX<AP
            DP = (p1max-p1min).*rand(1) + p1min;
        end

        if visual == 1
            % Labview desired position
            lvwrite(DP)
        end

        % Completed path from AP (at the moment of the new decided DP) to DP [Voltage]
        path(no, trial) = abs(DP - AP);
        
        % Core parameters
        doba(1,no)=0;
        m = 1;
        n = 1;
        u = 1;
        i = 1;
        % k = 1;
        RT(no)=0;
%         LearningTime = 1;
        timing(no) = tic;
        % signal=false;
        zaznam=0;
        count=0;
        countmax=1e7;
        % Output to Arduino

            while (toc(timing(no)) < TforDP) && (count < countmax) % always include a failsafe!
                count = count + 1;
                t(o)=toc(graf);
                
                i = i + 1;
                x(o)= o;
                xt(o)= toc(graf);
                outValue(o)= DP;
                kniplValue(o)= axis(joystick, 2);
                delta(i,no)= outValue(o)-kniplValue(o);
                                     
                if zaznam == 1 
                    errorAPDP(n,no) = delta(i,no);
                    doba(n,no)=t(o)-t(o-1);
                    n = n + 1;    
                end
                
                if (delta(i,no) >= -toleranceX) && (delta(i,no) <= toleranceX)
    
                    % if signal == false
                    %        holding = tic;
                    % end
                    % signal = true;
                    
                    if (m == 1) % first time reach
                        % Reaction time needed for movement from CP to DP
                        RT(no) = toc(timing(no));
                        zaznam=1;
                        m = m + 1;
    %                 elseif (m > 1) % staying in DP tolerance
    %                     HT(u,no) = toc(holding);
    %                     if (HT(u,no) >= maxholdingtime) && (LearningTime == 1)
    %                         LT(no) = toc(timing(no));
    %                         LearningTime = LearningTime + 1;
    %                     end
                        u = u + 1;
                     end
                    
                    if delta(i,no) > 0
                        poloha_A = neutral+(vnitrni_limit-neutral)/(max_difX)*(delta(i,no));
                    else
                        poloha_A = neutral+(neutral-vnejsi_limit)/(max_difX)*(delta(i,no));
                    end
                        
               elseif delta(i,no) < 0
                    % signal = false;
                    if delta(i,no) < -max_difX % required significant move back
                        poloha_A = vnejsi_limit;
                    else % required slight and proporcional move back
                        poloha_A = neutral+(neutral-vnejsi_limit)/(max_difX)*(delta(i,no));
                    end
                else
                    % signal = false;
                    if delta(i,no)>max_difX %required significant move forward
                        poloha_A = vnitrni_limit;
                    else  % required slight and proporcional move forward
                       poloha_A = neutral+(vnitrni_limit-neutral)/(max_difX)*(delta(i,no));
                    end
                                   
                end 

                
                poloha_A1=poloha_A+korekce;
                poloha_A2=poloha_A-korekce;
                if haptic == 1
                    writePosition(s1, poloha_A1);
                    writePosition(s2, poloha_A2);
                else
                    pause(0.02);
                end
                o = o + 1;
                
            end

     % Average error and deviation
        if RT(no)==0
            RT(no) = NaN;
        end
        if n == 1
            AE2(no) = NaN;
            DevAE2 = NaN;
            MEDP(no) = NaN;
        else
            n = n - 1;
            
            normdoba(1:n,no)=doba(1:n,no)/sum(doba(1:n,no));
            AE2(no) = sum(normdoba(1:n,no).*abs(errorAPDP(1:n,no)));
            DevAE2 = sqrt(var(errorAPDP(1:n,no),normdoba(1:n,no)));
            MEDP(no) = max(abs(errorAPDP(1:n,no)));
        end

        % Time of each desired position
        DPT(no) = toc(timing(no));
              
        no = no + 1;
        
    end
    stop_time = string(datetime('now', 'Format', 'dd.MM.yyyy HH:mm:ss'));
    fprintf('end of trial %g \n', trial)
    fprintf(newline)
    
    % Get screen size
    screenSize = get(0, 'ScreenSize');

    % Create a plot of comparison between desired and actual position
    figure(1);
    set(gca,'FontSize',22);
    plot(xt,kniplValue,'b','LineWidth',1);
    hold on;
    plot(xt,outValue,'r','LineWidth',1);
    plot(xt,outValue+toleranceX,'g','LineWidth',1);
    plot(xt,outValue-toleranceX,'g','LineWidth',1);
    title('Actual position & Target position');
    legend('Actual position', 'Target position','+- tolerance', 'Location', 'southeast');

    File_1=testcase+"rep"+repetition+".fig";
    saveas(figure(1), File_1);
    movefile(File_1,saveFolder) 
    hold off;
    originalPosition = get(gcf, 'Position');  % [x, y, width, height]

    % Define the new x-position (keeping the original height and width)
    newX = 0;  % Set the desired x-position on the left side
    newY = (screenSize(4) - originalPosition(4)) / 2;  % Center vertically on the screen

    % Set the new position while preserving the original size
    newPosition = [newX, newY, originalPosition(3), originalPosition(4)];

    % Apply the new position to figure(2)
    set(gcf, 'Position', newPosition);
    
if haptic == 1       
        writePosition(s1, neutral+korekce);
        writePosition(s2, neutral-korekce);
end

ExperimentTiming = toc(ET) ./ 60;
fprintf('Time need to comlete the experiment: %g min \n', ExperimentTiming)
% AA = sprintf('Experiment time [min]');

if haptic == 1
    clear s
    clear s1
    clear s2
end

% Reaction speed
no=no-1;

if RT(no)==0
    RT(no)=NaN;
end

% HTs = permute(HT, [2 1 3]);

EAPDP = permute(errorAPDP, [2 1 3]);

% Fitts law (Jan)

% Calculate ID_difficulty for each operation
ID_difficulty= log2(2*path/toleranceX);

% Calculate the regression line
include=~isnan(RT);
p = polyfit(ID_difficulty(include), RT(include), 1); % p(1) is the slope, p(2) is the intercept
y_fit = polyval(p, ID_difficulty(include)); % Fitted values
plot(ID_difficulty(include), y_fit, 'r-', 'LineWidth', 2); % Regression line

% Calculate Root Mean Squared Error (RMSE)
residuals = RT(include).' - y_fit;  
RMSE = sqrt(mean(residuals.^2));

% Generate the new plot: MT (Movement Time) vs ID_difficulty
figure(2);
set(gca, 'FontSize', 22);
set(gcf, 'Position', newPosition);
scatter(ID_difficulty, RT, 'b', 'filled'); % Points of MT vs ID_difficulty
hold on;

% Labels and title
xlabel('ID\_difficulty');
ylabel('MT (s)');
title('MT vs ID\_difficulty with Regression Line');
legend('Data', 'Regression Line', 'Location', 'northwest');
grid on;
hold off;

% Save the plot
File_2 = testcase + "rep" + repetition + "_MT_vs_ID.fig";
saveas(figure(2), File_2);
movefile(File_2, saveFolder);

% Define datasets and corresponding headers
datasets = {
    'resultsa', {'DPTs (s)', 'path (V)', 'RTs (s)', 'AE2 (V)', 'MEDP (V)', 'ID_difficulty'}, [DPT(:), path(:), RT(:), AE2(:), MEDP(:), ID_difficulty(:)];
    'resultsb', {'time (s)', 'AP (-)'}, [xt(:), kniplValue(:)];
    'resultsc', arrayfun(@(j) sprintf('errorAPDP_%d (V)', j), 1:size(errorAPDP, 2), 'UniformOutput', false), errorAPDP;
    'resultsd', {'DevAE2 (V)','paralel task', 'start_time', 'stop_time', 'slope', 'accuracy', 'intersection (with MT axis)'}, [DevAE2(:), paraleltask, start_time, stop_time, p(1), RMSE , p(2)]
};

% Loop through datasets and save each to a CSV file
for i = 1:size(datasets, 1)
    % Extract details
    csvFileName = datasets{i, 1}+ "_" + repetition + ".csv";
    headers = datasets{i, 2};
    data = datasets{i, 3};
    
    % Ensure headers match the number of columns in data
    numCols = size(data, 2);
    if numel(headers) ~= numCols
        % Adjust headers dynamically if necessary
        headers = arrayfun(@(j) sprintf('Column_%d', j), 1:numCols, 'UniformOutput', false);
        disp(['Warning: Adjusted headers for ', csvFileName, ' to match data dimensions.']);
    end

    % Define full path for the CSV file
    csvFile = fullfile(saveFolder, csvFileName);
    
    % Write headers and data
    writecell([headers; num2cell(data)], csvFile);
    
    % Confirm save
    disp(['Saved to: ', csvFile]);
end

lvwrite(0)
% Confirm the results were saved
disp(['Results saved to: ', csvFile]);

disp('Task finished.');
done =1;
% end
end
