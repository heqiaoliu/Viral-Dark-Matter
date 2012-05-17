% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $

function constructCSP(etm)

mapFileName = fullfile(matlabroot, ...
              'toolbox', 'simulink', 'simulink', 'private', 'configset_dependency.mat');
if exist(mapFileName, 'file')
    load(mapFileName);
else
    objective{1}='_export_To_File_';
    cspobj = rtw.codegenObjectives.ConfigSetProp;
    cspobj.construction(objective);
end

cspobj.appendParameter(etm.csCopyFrom);

etm.obj = cspobj;
parameters = cspobj.Parameters;
etm.nOfParams = length(parameters);

paramNames = cell(1, length(parameters));
paramIds   = cell(1, length(parameters));
[paramNames{:}] = parameters.name;
[paramIds{:}] = parameters.id;

hash = containers.Map(paramNames, paramIds);
etm.paramHash = hash;
