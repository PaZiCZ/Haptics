clear
close all


%Settings - Arduino - joy
if exist('s','var') == 0
    s = arduino('COM4','Leonardo');
end

    servo1Pin = 'D6';     % číslo pinu ovládání servo motoru 1 - L
    servo2Pin = 'D5';     % číslo pinu ovládání servo motoru 2 - P
    if exist('s1','var') == 0
      s1 = servo(s, servo1Pin);
    end
    if exist('s2','var') == 0
      s2 = servo(s, servo2Pin);
    end


%Settings
vnitrni_limit = 0.8; %aby moc nezajelo, vysunuty 0, zasunuty 1, default = 0.8
vnejsi_limit = 0.35; %aby nevyjelo a nevypadlo, default = 0.3
neutral = 0.65; %poloha kdyz joystick nepozaduje manevr, default = 0.57
% max_delta = 0.2; %maximalni diferencialni vychylka pro naklon joysticku na stranu, default = 0.1

max_difX = 1; %maximalni rozdil cilove a aktualni polohy, nad timto rozdilem uz je lista vzdy na limitu, default = 0.2

korekce=0.06; %0.027;

%POZOR - vnitrni_limit, vnejsi_limit, neutral, max_delta, min_ext, min_tilt
%jsou bezrozmerove polohy serv-a
%ALE - toleranceX, toleranceY, max_difX, max_difY
%jsou bezrozmerove polohy ale joysticku

    %nastaveni vychozi polohy serv
    writePosition(s1, neutral+korekce)
    writePosition(s2, neutral-korekce)
     % writePosition(s1, 0.69);
     % writePosition(s2, 0.53);
  % Pause
    % pause(1);
    % clear s1
    % clear s2