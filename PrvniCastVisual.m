%Script reads joystick position in X and Y and guides a human to randomly generated position

clear all
close all

%script identifier
si = 'The first part / randomly generated target positions';

% Specify folder
tester='00';
experiment_no='00';

% slozka="tester"+tester+"no"+experiment_no;
% jmenosouboru="te"+tester+"no"+experiment_no; %+".xlsx";
% 
% % if isfolder(slozka)
% %     disp('Toto mereni jiz existuje! Opravte cislo testera a experimentu a program znovu spustte.');
% %     %Uz nic, program naprazdno proleti
% % else
% 
% cesta=sprintf('F:\Zeta\Joystick\Learning\DruhyJoy');
% cestaslozka=strcat(cesta,slozka);
% mkdir(cestaslozka);

haptic = 1;
visual = 0;

%Settings - Arduino - joy
if exist('s','var') == 0
    s = arduino('COM4','Leonardo');
end

    servo1Pin = 'D6';     % èíslo pinu ovládání servo motoru 1 - L
    servo2Pin = 'D9';     % èíslo pinu ovládání servo motoru 2 - P
    if exist('s1','var') == 0
      s1 = servo(s, servo1Pin);
    end
    if exist('s2','var') == 0
      s2 = servo(s, servo2Pin);
    end


%Settings
vnitrni_limit = 0.8; %aby moc nezajelo, vysunuty 0, zasunuty 1, default = 0.8
vnejsi_limit = 0.35; %aby nevyjelo a nevypadlo, default = 0.3
neutral = 0.59; %poloha kdyz joystick nepozaduje manevr, default = 0.57
% max_delta = 0.2; %maximalni diferencialni vychylka pro naklon joysticku na stranu, default = 0.1

toleranceX = 0.05; %rozdil nad kterym joystick uz signalizuje, default = 0.025
max_difX = 0.5; %maximalni rozdil cilove a aktualni polohy, nad timto rozdilem uz je lista vzdy na limitu, default = 0.2

korekce=-0.013; %0.027;

%POZOR - vnitrni_limit, vnejsi_limit, neutral, max_delta, min_ext, min_tilt
%jsou bezrozmerove polohy serv-a
%ALE - toleranceX, toleranceY, max_difX, max_difY
%jsou bezrozmerove polohy ale joysticku
T0 = 3; %
Maxno = 20;    % Number of DP 

% rozsah joysticku - bylo by dobré to ovìøit nìjakou kalibrací
p1min = -1;
p1max = 1;

    %nastaveni vychozi polohy serv
    writePosition(s1, neutral+korekce);
    writePosition(s2, neutral-korekce);

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
                        
               elseif delta(i,no) < -toleranceX
                    signal = false;
                    if delta(i,no) < -max_difX % required significant move back
                        poloha_A = vnejsi_limit;
                    else % required slight and proporcional move back
                        poloha_A = neutral+(neutral-vnejsi_limit)/(max_difX)*(delta(i,no));
                    end
               elseif delta(i,no) > toleranceX
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
        
%         if LearningTime == 1
%            LT(no) = NaN;
%         end
        
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
    title('Actual position & Desired position');
    legend('Actual position', 'Desired position','+- tolerance', 'Location', 'southeast');
    % Save the plot
%     File_1 = sprintf('%s.fig',jmenosouboru(1:strfind(jmenosouboru,'.')-1));
    File_1 = "fig.fig";
%     saveas(figure(1), File_1);
%     movefile(File_1,slozka) 
    hold off;
    
    
        poloha_A = neutral;
        poloha_S = 0;
            
        poloha_L = poloha_A-poloha_S;
        poloha_P = poloha_A+poloha_S;

        
        writePosition(s1, poloha_L);
        writePosition(s2, poloha_P);
        
ExperimentTiming = toc(ET) ./ 60;
fprintf('Time need to comlete the experiment: %g min \n', ExperimentTiming)
AA = sprintf('Experiment time [min]');
warning( 'off', 'MATLAB:xlswrite:AddSheet' );
% xlswrite(jmenosouboru,{AA},'ET (min)', 'A1');
% xlswrite(jmenosouboru, ExperimentTiming,'ET (min)', 'B1');

clear s

% Reaction speed
no=no-1;

if RT(no)==0
    RT(no)=NaN;
end

% HTs = permute(HT, [2 1 3]);

EAPDP = permute(errorAPDP, [2 1 3]);

% Data saving in excel file
jmenosouboru = "test.xlsx";    
    warning( 'off', 'MATLAB:xlswrite:AddSheet');
    
    xltitlerange = sprintf('A%g');
    row = sprintf('trial n° %g');
        
        xltitlerange = sprintf('A%g');
        row = sprintf('trial n° %g');
        xlswrite(jmenosouboru, {row}, 'doba (s)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'DPTs (s)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'path (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'RTs (s)', xltitlerange);        
        xlswrite(jmenosouboru, {row}, 'AE2 (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'DevAE2 (V)', xltitlerange);
%         xlswrite(jmenosouboru, {row}, 'HTs (s)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'MEDP (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'errorAPDP (V)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'outValue (-)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'kniplValue (-)', xltitlerange);
        xlswrite(jmenosouboru, {row}, 'xt (t)', xltitlerange);
        xlr = sprintf('B%g');

        %if haptic ==1
        xlswrite(jmenosouboru, doba(:,:), 'doba (s)', xlr);
        %end

        xlswrite(jmenosouboru, DPT(:), 'DPTs (s)', xlr);
        xlswrite(jmenosouboru, path(:), 'path (V)', xlr);
        xlswrite(jmenosouboru, RT(:), 'RTs (s)', xlr);
         xlswrite(jmenosouboru, AE2(:), 'AE2 (V)', xlr);
        xlswrite(jmenosouboru, DevAE2(:), 'DevAE2 (V)', xlr);
%         xlswrite(jmenosouboru, HTs(:,:), 'HTs (s)', xlr);
        xlswrite(jmenosouboru, MEDP(:), 'MEDP (V)', xlr);
        
        %if haptic ==1
        xlswrite(jmenosouboru, EAPDP(:,:), 'errorAPDP (V)', xlr);
        xlswrite(jmenosouboru, outValue(:), 'outValue (-)', xlr);
        xlswrite(jmenosouboru, kniplValue(:), 'kniplValue (-)', xlr);
        xlswrite(jmenosouboru, xt(:), 'xt (t)', xlr);
        %end

% movefile(jmenosouboru,slozka);   %move file with all basic data in subject folder

disp('Experiment finished.');
% end
