% spec.m

% Experiment specifications
tester = '01';
experiment_no = '10';
variant = '11';

% haptic and visual flags
haptic = 1;
visual = 0;

% Sliding element setting 
vnitrni_limit = 0.8; %aby moc nezajelo, vysunuty 0, zasunuty 1, default = 0.8
vnejsi_limit = 0.35; %aby nevyjelo a nevypadlo, default = 0.3
neutral = 0.625; %poloha kdyz joystick nepozaduje manevr, default = 0.57

korekce=0.075; %0.027;

%POZOR - vnitrni_limit, vnejsi_limit, neutral, max_delta, min_ext, min_tilt
%jsou bezrozmerove polohy serv-a
%ALE - toleranceX, toleranceY, max_difX, max_difY
%jsou bezrozmerove polohy ale joysticku

max_difX = 0.7; %maximalni rozdil cilove a aktualni polohy, nad timto rozdilem uz je lista vzdy na limitu, default = 0.2
toleranceX = 0.05; % tolerance to define target position interval (only Task 1)
threshold = 0.025;  %rozdil nad kterym joystick uz signalizuje, default = 0.025