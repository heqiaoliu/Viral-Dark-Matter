function [fcnPath,fcnId]=irDecodeBlockPath(scriptPath)   

% Copyright 2008-2010 The MathWorks, Inc.

% The first character is #, and the rest is the script SID
sfObj = Simulink.ID.getHandle(scriptPath(2:end));

if isfloat(sfObj)
    chartId = sfprivate('block2chart',sfObj);
    rt = sfroot;
    sfObj = rt.idToHandle(chartId);
end


if sfObj.isa('Stateflow.EMChart')
    fcnPath = sfObj.getFullName;
    fcnId = sfprivate('eml_fcns_in',sfObj.Id);
elseif sfObj.isa('Stateflow.EMFunction')
    fcnPath = sprintf('%s/Embedded MATLAB Function',sfObj.getFullName);
    fcnId = sfObj.Id;
else
    fcnPath = '';
    fcnId = -1;
end

