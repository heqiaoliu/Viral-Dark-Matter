function	[sfLinkMachines,sfLinkLibFullPaths,sfLinkInfoFullPaths]  = get_link_machine_list(machineName,targetName)
%
%
%	Copyright 1995-2008 The MathWorks, Inc.
%	$Revision: 1.9.2.4 $

if ~ischar(machineName)
    machineId = machineName;
    machineName = sf('get',machineId,'machine.name');
else
    machineId = sf('find','all','machine.name',machineName);
end

sfLinkMachines = [];
sfLinkLibFullPaths = [];
sfLinkInfoFullPaths = [];
linkCharts = sf('get',machineId,'machine.sfLinks');
if(isempty(linkCharts) || sf('get',machineId,'machine.isLibrary'))
    return;
end
linkMachineHandles = [];
for i = 1:length(linkCharts)
    linkChart = linkCharts(i);
    refChart = get_param(linkChart,'referenceblock');
    refMachineHandle = get_root_handle(refChart);
    if(isempty(linkMachineHandles))
        linkMachineHandles = refMachineHandle;
    else
        linkMachineHandles = [linkMachineHandles;refMachineHandle];
    end
end
linkMachineHandles = unique(linkMachineHandles);

numMachines = length(linkMachineHandles);
if(numMachines>1)
    sfLinkMachines = get_param(linkMachineHandles,'name');
else
    sfLinkMachines{1} = get_param(linkMachineHandles,'name');
end

sort(sfLinkMachines);
if(isunix)
    libext = 'a';
else
    libext = 'lib';
end

for i=1:length(sfLinkMachines)
    sfProj = get_sf_proj(pwd,machineName,sfLinkMachines{i},'sfun','src');
    sfLinkLibFullPaths{i} = fullfile(sfProj,[sfLinkMachines{i},'_',targetName,'.',libext]);
    
    sfInfo = get_sf_proj(pwd,machineName,sfLinkMachines{i},'sfun','info');
    sfLinkInfoFullPaths{i} = fullfile(sfInfo,'binfo.mat');
end

return;




function rootHandle = get_root_handle(blkName)

e = find(blkName=='/', 1 );
if(~isempty(e))
    str = blkName(1:e-1);
else
    str = blkName;
end
try
    rootHandle = get_param(str,'handle');
catch
    feval(str,[],[],[],'load');
    rootHandle = get_param(str,'handle');
end




