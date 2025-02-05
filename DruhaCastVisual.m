%Script reads joystick position in X and Y and guides a human to predefined smoothly changing position

clear all
close all

%script identifier
si = 'The second part, continuouslz changing position';

% Specify folder
tester='08';
experiment_no='02';
variant='09';

haptic = 0;
visual = 1;

% folder="tester"+tester+"no"+experiment_no;
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


f=fullfile('C:\Users\zikmund\Downloads\Thesis(255678)\Thesis(255678)\measurement',slozka);

if isfile(fullfile(f,filename2+".csv"))
    disp('The measurement exists! Correct experiment identifiers and run it again.');
    %The code will not run and ends
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
%Settings

vnitrni_limit = 0.8; %aby moc nezajelo, vysunuty 0, zasunuty 1, default = 0.8
vnejsi_limit = 0.35; %aby nevyjelo a nevypadlo, default = 0.3
neutral = 0.63; %poloha kdyz joystick nepozaduje manevr, default = 0.57

toleranceX = 0.05; %rozdil nad kterym joystick uz signalizuje, default = 0.025
max_difX = 0.5; %maximalni rozdil cilove a aktualni polohy, nad timto rozdilem uz je lista vzdy na limitu, default = 0.2
korekce=0.027;


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
    title('Actual position & Desired position');
    legend('Actual position', 'Desired position','+- tolerance', 'Location', 'southeast');
   
    File_1=jmenosouboru+".fig";
    saveas(figure(1), File_1);
    movefile(File_1,slozka) 
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

jmenosouboru = jmenosouboru+".xlsx";
% xlswrite(jmenosouboru,{AA},'ET (min)', 'A1');
% xlswrite(jmenosouboru, ExperimentTiming,'ET (min)', 'B1');
warning( 'off', 'MATLAB:xlswrite:AddSheet' );

% Data saving in excel file
    
    warning( 'off', 'MATLAB:xlswrite:AddSheet');
    
        xltitlerange = sprintf('A%g');
        row = sprintf('trial n° %g');        
        xlswrite(jmenosouboru, {row}, 'path (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'AP (-)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'DP (-)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 't (s)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'AE2 (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'DevAE2 (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'MEDP (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'errorAPDP (V)', xltitlerange);
        xlr = sprintf('B%g');       
        xlswrite(jmenosouboru, path(:), 'path (V)', xlr);
        xlswrite(jmenosouboru, AP(:), 'AP (-)', xlr);
        xlswrite(jmenosouboru, DP(:), 'DP (-)', xlr);
        xlswrite(jmenosouboru, t(:), 't (s)', xlr);
        xlswrite(jmenosouboru, AE2(:), 'AE2 (V)', xlr);
        xlswrite(jmenosouboru, DevAE2(:), 'DevAE2 (V)', xlr);        
        xlswrite(jmenosouboru, MEDP(:), 'MEDP (V)', xlr);       
        xlswrite(jmenosouboru, EAPDP(:,:), 'errorAPDP (V)', xlr);
 

movefile(jmenosouboru,slozka);

disp('Experiment finished.');
clear
end
