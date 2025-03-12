%Script reads joystick position in X and Y and guides a human to predefined smoothly changing position
function [done] = DruhaCastVisual(tester, experiment_no, haptic, visual, paraleltask, repetition, testcase, variant, saveFolder)
% clear
% close all

%script identifier
si = 'Task 2, continuously changing position';

run('spec.m');

% variables from specification file
disp(['Tester: ', num2str(tester)]);
disp(['Experiment Number: ', num2str(experiment_no)]);
disp(['Haptic: ', num2str(haptic)]);
disp(['Visual: ', num2str(visual)]);
disp(['Paralel: ', num2str(paraleltask)]);
disp(['Variant: ', num2str(variant)]);

% folder="tester"+tester+"no"+experiment_no;
addpath('E:\Thesis255678\var01-12')
Test = load("var"+variant+".mat"); 
% testcase="te"+tester+"no"+experiment_no; 
saveFolder = fullfile('E:\Thesis255678\measurement', testcase);
filename2="te"+tester+"no"+experiment_no+"var"+variant;


% 
poloha=Test.poloha;
[radky,h]=size(poloha);
maxT=poloha(radky,2);


if haptic == 1
   % initial servo position
    writePosition(s1, neutral+korekce);
    writePosition(s2, neutral-korekce);
end

% Definuje ID snimaneho joysticku/pedalu, obycejne se pedaly hlasi na ID 1
ID = 1;
% Definuje snimany joystick/pedaly
joystick=vrjoystick(ID);

%chovani joystick:
%osa pitch - X, osa2, kladna vychylka je pritazeni

done = 0;
ticstart = 1;
ET = tic;
i=1;
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
    count=0;
    graf=tic;
    doba(1)=0;
    
    % Begin while loop representing one trial 
    while toc(graf) < maxT  && (count < countmax)
        count = count + 1;
        t(o)=toc(graf);
        if o>1
            doba(o)=t(o)-t(o-1);
        end
        % Actual position
        AP(o) = axis(joystick, 2);  
        
        % Desired (target) position - interpolation from prerecorded file
        DP(o) = interp1(poloha(:,2),poloha(:,1),t(o));  

        if visual == 1
            % Labview desired position
            lvwrite(DP(o))
        end

        % Completed path from AP (at the moment of the new decided DP) to DP [Voltage]
        delta(o)=DP(o) - AP(o);
        path(o) = abs(delta(o));
          
        errorAPDP(o) = delta(o);

        if haptic == 1
     
            if delta(o) > max_difX
                poloha_A = vnitrni_limit;
            elseif delta(o) >= 0
                poloha_A = neutral+(vnitrni_limit-neutral)/(max_difX)*(delta(o));
            elseif delta(o)< -max_difX
                poloha_A = vnejsi_limit;
            else
                poloha_A = neutral+(neutral-vnejsi_limit)/(max_difX)*(delta(o));
            end
           
           writePosition(s1, poloha_A+korekce);
           writePosition(s2, poloha_A-korekce);
           else
                    pause(0.02);
        end

            o = o + 1;
       
    end
    stop_time = string(datetime('now', 'Format', 'dd.MM.yyyy HH:mm:ss'));
     % Average error and deviation
            n = o - 1;
            normdoba(1:n)=doba(1:n)/sum(doba(1:n));
            AE2 = sum(normdoba(1:n).*abs(errorAPDP(1:n)));
            DevAE2 = sqrt(var(errorAPDP(1:n),normdoba(1:n)));
            
             
        
    % Maximum error between AP and DP
    MEDP = max(abs(errorAPDP));
    % Maximum overdraft
    
    
    % Create a plot of comparison between desired and actual position
    figure(1);
    set(gca,'FontSize',22);
    plot(t,AP,'b','LineWidth',1);
    hold on;
    plot(t,DP,'r','LineWidth',1);
    plot(t,DP+toleranceX,'g','LineWidth',1);
    plot(t,DP-toleranceX,'g','LineWidth',1);
    title('Actual position & Target position');
    legend('Actual position', 'Target position','+- tolerance', 'Location', 'southeast');
   
    File_1=filename2+"rep"+repetition+".fig";
    saveas(figure(1), File_1);
    movefile(File_1,saveFolder) 
    hold off;
    %close all;
    
    if haptic == 1

        poloha_A = neutral;
           
        writePosition(s1, poloha_A+korekce);
        writePosition(s2, poloha_A-korekce);

    end
    
ExperimentTiming = toc(ET) ./ 60;
fprintf('Time need to comlete the experiment: %g min \n', ExperimentTiming)
AA = sprintf('Experiment time [min]');

clear s
EAPDP = permute(errorAPDP, [2 1 3]);

% Define datasets and corresponding headers
datasets = {
    'resultsT2a', {'t (s)', 'DP (-)','AP (-)','path (V)'}, [t(:), DP(:), AP(:), path(:) ];
    'resultsT2b', {'AE2 (V)','DevAE2 (V)', 'MEDP (V)'}, [AE2(:), DevAE2(:), MEDP(:)];
    'resultsT2c', {'paralel task', 'start_time', 'stop_time'}, [paraleltask, start_time, stop_time]
};

% Loop through datasets and save each to a CSV file
for i = 1:size(datasets, 1)
    % Extract details
    csvFileName = datasets{i, 1}+ "_" + repetition+ ".csv";
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

% clear
end

