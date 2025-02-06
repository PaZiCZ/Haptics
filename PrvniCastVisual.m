%Script reads joystick position in X and Y and guides a human to randomly generated position

clear
close all

%script identifier
si = 'The first part / randomly generated target positions';

run('spec.m');

% variables from specification file
disp(['Tester: ', tester]);
disp(['Experiment Number: ', experiment_no]);
disp(['Haptic: ', num2str(haptic)]);
disp(['Visual: ', num2str(visual)]);

% folder="tester"+tester+"no"+experiment_no;
testcase="te"+tester+"no"+experiment_no; 
saveFolder = fullfile('C:\Users\zikmund\Downloads\Thesis255678\measurement', testcase);

% Ensure the folder exists; create it if it doesn't
if ~isfolder(saveFolder)
    mkdir(saveFolder);
    disp(['Created folder: ', saveFolder]);
else
    disp(['Folder already exists: ', saveFolder]);
    disp('DO NOT CONTINUE');
end

%Settings - Arduino - joy
if haptic == 1
    if exist('s','var') == 0
        s = arduino('COM4','Leonardo');
    end

    servo1Pin = 'D6';     % pin number for left servo - 1 
    servo2Pin = 'D5';     % pin number for right servo - 2
    if exist('s1','var') == 0
        s1 = servo(s, servo1Pin);
    end
    if exist('s2','var') == 0
      s2 = servo(s, servo2Pin);
    end

end

T0 = 3; %
Maxno = 6;    % Number of DP 

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

% Begin while loop for Nr. of trials - to see improvements through practice

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
        count=0;
        m = 1;
        n = 1;
        u = 1;
        i = 1;
        k = 1;
        RT(no)=0;
%         LearningTime = 1;
        timing(no) = tic;
        signal=false;
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
    
                    if signal == false
                           holding = tic;
                    end
                    signal = true;
                    
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
                        
               elseif delta(i,no) < -threshold
                    signal = false;
                    if delta(i,no) < -max_difX % required significant move back
                        poloha_A = vnejsi_limit;
                    else % required slight and proporcional move back
                        poloha_A = neutral+(neutral-vnejsi_limit)/(max_difX)*(delta(i,no));
                    end
               elseif delta(i,no) > threshold
                    signal = false;
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
    
    fprintf('end of trial %g \n', trial)
    fprintf(newline)
    
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

    File_1=testcase+".fig";
    saveas(figure(1), File_1);
    movefile(File_1,saveFolder) 
    hold off;
    
    
if haptic == 1       
        writePosition(s1, neutral+korekce);
        writePosition(s2, neutral-korekce);
end

ExperimentTiming = toc(ET) ./ 60;
fprintf('Time need to comlete the experiment: %g min \n', ExperimentTiming)
AA = sprintf('Experiment time [min]');

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

% Define datasets and corresponding headers
datasets = {
    'resultsa.csv', {'DPTs (s)', 'path (V)', 'RTs (s)', 'AE2 (V)', 'MEDP (V)'}, [DPT(:), path(:), RT(:), AE2(:), MEDP(:)];
    'resultsb.csv', {'time (s)', 'AP (-)'}, [xt(:), kniplValue(:)];
    'resultsc.csv', arrayfun(@(j) sprintf('errorAPDP_%d (V)', j), 1:size(errorAPDP, 2), 'UniformOutput', false), errorAPDP;
    'resultsd.csv', {'DevAE2 (V)'}, DevAE2(:)
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
% end
