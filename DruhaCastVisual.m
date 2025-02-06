%Script reads joystick position in X and Y and guides a human to predefined smoothly changing position

clear
close all

%script identifier
si = 'The second part, continuouslz changing position';

run('spec.m');

% variables from specification file
disp(['Tester: ', tester]);
disp(['Experiment Number: ', experiment_no]);
disp(['Haptic: ', num2str(haptic)]);
disp(['Visual: ', num2str(visual)]);
disp(['Variant: ', variant]);

% folder="tester"+tester+"no"+experiment_no;
addpath('C:\Users\zikmund\Downloads\Thesis255678\GitHub\var01-12')
Test = load("var"+variant+".mat");
testcase="te"+tester+"no"+experiment_no; 
saveFolder = fullfile('C:\Users\zikmund\Downloads\Thesis255678\measurement', testcase);
filename2="te"+tester+"no"+experiment_no+"var"+variant;

% Ensure the folder exists; create it if it doesn't
if isfolder(saveFolder)
    
    disp(['The folder exists from Task 1: ', saveFolder]);
else
    disp(['Folder created: ', saveFolder]);
    mkdir(saveFolder);
    disp('Task 1 is not saved!!!!');
end

    fileNameresults = "resultsT2a.csv";
if isfile(fullfile(saveFolder, fileNameresults))
    disp('The file exists in the folder.');
else

 %Settings - Arduino - joy
if exist('s','var') == 0
    s = arduino('COM4','Leonardo');
end

if haptic == 1
    servo1Pin = 'D6';     % pin number for left servo - 1 
    servo2Pin = 'D5';     % pin number for right servo - 2
    if exist('s1','var') == 0
      s1 = servo(s, servo1Pin);
    end
    if exist('s2','var') == 0
      s2 = servo(s, servo2Pin);
    end
end

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

ticstart = 1;
ET = tic;
i=1;
countmax=1e7;
count=0;

position(i)= axis(joystick, 2);
z = position(i) - 0.25;
w = position(i) + 0.25;   
    disp('Do not push to a sliding element during the experiment!')
    disp('To begin the experiment move with the joystick forward and back')
  
% Begin while loop that enables desired pause between subsequent trials
while (position(i) > z ) && (position(i) < w )&& (count < countmax)
    position(i) = axis(joystick, 2);
    count = count + 1;
end
    
% Pause
pause(1);
    
% Starting sequence
disp('Start in 3 seconds, get ready!');
for i = 1:3
    pause(1);
    fprintf('%1.0f    ',i);
end
pause(0.5)
disp('START!')
   
    
% Trail begins
pause(1);

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
   
    File_1=filename2+".fig";
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
    'resultsT2a.csv', {'t (s)', 'DP (-)','AP (-)','path (V)'}, [t(:), DP(:), AP(:), path(:) ];
    'resultsT2b.csv', {'AE2 (V)','DevAE2 (V)', 'MEDP (V)'}, [AE2(:), DevAE2(:), MEDP(:)]
};

% Loop through datasets and save each to a CSV file
for i = 1:size(datasets, 1)
    % Extract details
    csvFileName = datasets{i, 1};
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


% Confirm the results were saved
disp(['Results saved to: ', csvFile]);

disp('Experiment finished.');


clear
end
