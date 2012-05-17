function [projectDirPath,projectDirArray,projectDirRelPath, projectDirReverseRelPath] = ...
     get_sf_proj(startDir,mainMachineName,machineName,targetName,srcOrInfo)

%   Copyright 2007-2009 The MathWorks, Inc.

startDir = get_sf_proj_root(startDir); 

projectDirArray = {startDir,'slprj','_sfprj'};

if(nargin>1)
    % this is a call that provides machine and target names as well
    if(strcmp(machineName,mainMachineName))
        projectDirArray = [projectDirArray,{mainMachineName,'_self',targetName}];
    else
        projectDirArray = [projectDirArray,{mainMachineName,machineName,targetName}];
    end    

    if(strcmp(targetName,'rtw'))
        try
            mainMachineType = get_param(mainMachineName,'BlockDiagramType');
        catch ME
            disp(ME.message);
            warning('Stateflow:UnexpectedError','%s not loaded yet. Forcing the model to load in order to infer the project directory for RTW target',mainMachineName);
            load_system(mainMachineName);
            mainMachineType = get_param(mainMachineName,'BlockDiagramType');
        end
        my_assert(~strcmpi(mainMachineType,'library'),'main machine should not be a library');
        cs = getActiveConfigSet(mainMachineName);
        systemTargetFile = get_param(cs,'SystemTargetFile');
        [~,systemTargetFileName] = fileparts(systemTargetFile);
        projectDirArray{end+1} = systemTargetFileName;
    end
    projectDirArray{end+1} = srcOrInfo;
end

projectDirPath = fullfile(projectDirArray{:});
projectDirRelPath = fullfile(projectDirArray{2:end});

projectDirReverseRelPath = '';
for i=1:length(projectDirArray)-1
    projectDirReverseRelPath = [projectDirReverseRelPath,'..',filesep]; %#ok<AGROW>
end  


function my_assert(expr,message)

if(~expr)
    assert(expr,message);
end
