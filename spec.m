% spec.m
% Experiment specifications

% tester = participant_no;
% experiment_no = '08'; 
% variant = '11';

Maxno = 5;    % Number of target position in Task 1 
toleranceX = 0.1; % tolerance to define target position interval (only Task 1)

% haptic and visual flags
% haptic = 1;
% visual = 0;

%Settings - Arduino - joy
if haptic == 1

% Sliding element setting 
vnitrni_limit = 0.8; %aby moc nezajelo, vysunuty 0, zasunuty 1, default = 0.8
vnejsi_limit = 0.35; %aby nevyjelo a nevypadlo, default = 0.3
neutral = 0.625; %poloha kdyz joystick nepozaduje manevr, default = 0.57

korekce=0.06; %0.027;

%POZOR - vnitrni_limit, vnejsi_limit, neutral, max_delta, min_ext, min_tilt
%jsou bezrozmerove polohy serv-a
%ALE - toleranceX, toleranceY, max_difX, max_difY
%jsou bezrozmerove polohy ale joysticku

max_difX = 1.0; %maximalni rozdil cilove a aktualni polohy, nad timto rozdilem uz je lista vzdy na limitu, default = 0.2

threshold = 0.0;  %rozdil nad kterym joystick uz signalizuje, default = 0.025


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