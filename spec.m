% spec.m
% Experiment specifications

% tester = participant_no;
% experiment_no = '08'; 
% variant = '11';

Maxno = 20;    % Number of target position in Task 1 
toleranceX = 0.1; % tolerance to define target position interval (only Task 1)

% haptic and visual flags
% haptic = 1;
% visual = 0;

%Settings - Arduino - joy


% Sliding element setting 
vnitrni_limit = 0.8; %aby moc nezajelo, vysunuty 0, zasunuty 1, default = 0.8
vnejsi_limit = 0.35; %aby nevyjelo a nevypadlo, default = 0.3
neutral = 0.63; %poloha kdyz joystick nepozaduje manevr, default = 0.57

korekce=0.06; %0.027;


% SEthreshold = 0.025;  %threshold of the actual and target positions distance where sliding element start to signalize, default = 0.025
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

max_difX = 0.75; % difference of the actual and target positions when sliding element reach maximum deflection, default = 0.2
