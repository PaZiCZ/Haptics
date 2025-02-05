warning off
answer = inputdlg({'Remote LabVIEW Host:','Timeout (seg):'},'LanVIEW Interface',1,{'localhost','0.5'});
if ~isempty(answer)
labview_interface(answer{1},10000,str2num(answer{2}))
end
clear answer