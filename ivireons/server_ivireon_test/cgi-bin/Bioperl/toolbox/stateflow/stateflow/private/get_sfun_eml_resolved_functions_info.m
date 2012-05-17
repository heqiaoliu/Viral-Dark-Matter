function resolvedFunctions = get_sfun_eml_resolved_functions_info(machineName,mainMachineName)

%   Copyright 2008 The MathWorks, Inc.

targetName = 'sfun';
targetName0 = get_eml_metadata_target_name(targetName);
machineName0 = get_eml_metadata_machine_name(machineName);

mainMachineId = sf('find','all','machine.name',mainMachineName);
rebuildMetaData = sf('get',mainMachineId,'.eml.rebuildMetaData');
if isempty(rebuildMetaData)
    rebuildMetaData = struct();
    sf('set',mainMachineId,'.eml.rebuildMetaData',rebuildMetaData);    
end
if ~isfield(rebuildMetaData, targetName0) || ~isfield(rebuildMetaData.(targetName0), machineName0)
    machineId = sf('find','all','machine.name',machineName);
    chartIds = sf('get',machineId,'machine.charts');
    chartFiles = sort(sf('get',chartIds,'chart.chartFileNumber')'); %#ok<UDIM>
    rebuildMetaData.(targetName0).(machineName0).resolvedFunctionsInfo = [];
    rebuildMetaData.(targetName0).(machineName0).rebuildChartFiles = [];
    rebuildMetaData.(targetName0).(machineName0).rebuiltChartFiles = chartFiles;
end

resolvedFunctions = rebuildMetaData.(targetName0).(machineName0).resolvedFunctionsInfo;

% Cleanup all references to these rebuilt chart files
resolvedFunctions0 = [];
rebuiltChartFiles = sort(rebuildMetaData.(targetName0).(machineName0).rebuiltChartFiles);
for i = 1:numel(resolvedFunctions)
    resolvedFunction = resolvedFunctions(i);
    chartFiles = resolvedFunction.chartFiles;
    newChartFiles = [];
    for chartFile = chartFiles
        if binsearch(rebuiltChartFiles,chartFile) == 0
            newChartFiles(end+1) = chartFile;
        end
    end
    if ~isempty(newChartFiles)
        resolvedFunction.chartFiles = newChartFiles;
        resolvedFunctions0 = [resolvedFunctions0 resolvedFunction];
    end
end
resolvedFunctions = resolvedFunctions0;

sfunName = [mainMachineName '_' targetName];
sfunFileName = [sfunName,'.', mexext];
sfunExists = exist(sfunFileName,'file');

% Create a hash map (using structures) of all resolved functions
newResolvedFunctionsMap = struct();
for i = 1:numel(resolvedFunctions)
    resolvedFunction = resolvedFunctions(i);
    key = get_key(resolvedFunction);
    hashKey = get_hash_key(key);
    if isfield(newResolvedFunctionsMap,hashKey)
        resolvedFunctions0 = [newResolvedFunctionsMap.(hashKey) resolvedFunction];
    else
        resolvedFunctions0 = resolvedFunction;
    end
    newResolvedFunctionsMap.(hashKey) = resolvedFunctions0;
end

for i = 1:numel(rebuiltChartFiles)
    rebuiltChartFile = rebuiltChartFiles(i);
    chartResolvedFunctions = [];
    if sfunExists
        oldAccel = feature('accel','off');
        try
            chartResolvedFunctions = feval(sfunName, 'get_eml_resolved_functions_info', machineName, rebuiltChartFile);
        catch
            chartResolvedFunctions = [];
        end
        feature('accel',oldAccel);
    end
    for j = 1:numel(chartResolvedFunctions)
        resolvedFunction = chartResolvedFunctions(j);
        key = get_key(resolvedFunction);
        hashKey = get_hash_key(key);
        if isfield(newResolvedFunctionsMap,hashKey)
            resolvedFunctions = newResolvedFunctionsMap.(hashKey);
            found = false;
            for k = 1:numel(resolvedFunctions)
                f = resolvedFunctions(k);
                if strcmp(key,get_key(f))
                    resolvedFunctions(k).chartFiles = sort([resolvedFunctions(k).chartFiles rebuiltChartFile]);
                    found = true;
                    break;
                end
            end
            if ~found
                resolvedFunction.chartFiles = rebuiltChartFile;
                resolvedFunctions = [resolvedFunctions resolvedFunction];
            end
            newResolvedFunctionsMap.(hashKey) = resolvedFunctions;
        else
            newResolvedFunctionsMap.(hashKey) = resolvedFunction;
            newResolvedFunctionsMap.(hashKey).chartFiles = rebuiltChartFile;
        end
    end
end
% Create new resolved functions from hash map
resolvedFunctions = [];
names = fieldnames(newResolvedFunctionsMap);
for i = 1:numel(names)
    resolvedFunctions0 = newResolvedFunctionsMap.(names{i});
    for j = 1:numel(resolvedFunctions0)
        resolvedFunctions = [resolvedFunctions resolvedFunctions0(j)];
    end
end

function key = get_hash_key(k)
    len = numel(k);
    h = uint32(len);
    c = uint32(16777215);
    for i = 1:numel(k)
        h = bitand(h*31+uint32(k(i)),c);
    end
    key = ['k' num2str(h)];

function k = get_key(e)
    k = [e.context '__' e.name '__' e.dominantType];
