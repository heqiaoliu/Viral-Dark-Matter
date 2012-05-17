function ok = sync_eml_resolved_functions(machineId,mainMachineId,targetNameOrId)

%   Copyright 2006-2008 The MathWorks, Inc.

if isa(targetNameOrId,'numeric')
    targetName = sf('get',targetNameOrId,'target.name');
else
    targetName = targetNameOrId;
end

machineName = sf('get',machineId,'machine.name');
mainMachineName = sf('get',mainMachineId,'machine.name');

rebuildMetaData = sf('get',mainMachineId,'.eml.rebuildMetaData');
if isempty(rebuildMetaData)
    % The metaData is a structure that maps:
    %     'sfun'.'machineName' -> rebuildInfo
    %     'rtw'.'machineName' -> rebuildInfo
    %     'hdl'.'machineName' -> rebuildInfo, etc.
    % Where 'rebuildInfo' is a structure containing:
    %      resolvedFunctionsInfo (with a log of EML name resolutions)
    %      rebuildChartFiles (sorted list of chart files to rebuild)
    %      rebuiltChartFiles (sorted list of chart files that was rebuilt)
    rebuildMetaData = struct();
    sf('set',mainMachineId,'.eml.rebuildMetaData',rebuildMetaData);
end
    
% Check if we have rebuildMetaData for this target, otherwise create the
% information
rebuildAll = false;
targetName0 = get_eml_metadata_target_name(targetName);
machineName0 = get_eml_metadata_machine_name(machineName);
if ~isfield(rebuildMetaData, targetName0)
    chartIds = sf('get',machineId,'machine.charts');
    chartFiles = sort(sf('get',chartIds,'chart.chartFileNumber')'); %#ok<UDIM>
    rebuildMetaData.(targetName0).(machineName0).resolvedFunctionsInfo = [];
    rebuildMetaData.(targetName0).(machineName0).rebuildChartFiles = [];
    rebuildMetaData.(targetName0).(machineName0).rebuiltChartFiles = chartFiles;
end
if strcmp(targetName, 'sfun')
    sfunName = [mainMachineName '_' targetName];
    sfunFileName = [sfunName,'.', mexext];
    sfunExists = exist(sfunFileName,'file');
    resolvedFunctions = get_sfun_eml_resolved_functions_info(machineName,mainMachineName);
    rebuildMetaData.(targetName0).(machineName0).resolvedFunctionsInfo = resolvedFunctions;
    if sfunExists % Don't clear rebuilt files if there is no sfun! (It will hopefully try again some other time)
        rebuildMetaData.(targetName0).(machineName0).rebuiltChartFiles = [];
    end
else
    infoStruct = infomatman('load', 'binary', machineId, mainMachineId, targetName);
    if isfield(infoStruct, 'emlRebuildMetaData') && isfield(infoStruct.emlRebuildMetaData, machineName0)
        rebuildMetaData.(targetName0).(machineName0) = infoStruct.emlRebuildMetaData.(machineName0);
    else
        rebuildMetaData.(targetName0).(machineName0).resolvedFunctionsInfo = [];
        rebuildAll = true;
    end
    % Check if meta data is available in memory
    resolvedFunctions = rebuildMetaData.(targetName0).(machineName0).resolvedFunctionsInfo;
end

% If the target is the sfun DLL, then we iterate through all the rebuilt charts
% and build up the global database with the common name resolutions. This
% is referred to resolvedFunctionsInfo. Every resolvedFunctionsInfo record
% has an extra field called chartFiles which tells which chart files are
% containing this record; hence if the record fails name resolution
% verification, that chart needs a rebuild.
%

targetId = acquire_target(machineId,targetName);
% Find all charts with erroneous name resolutions (these need to be
% rebuilt)

if rebuildAll
    chartIds = sf('get',machineId,'machine.charts');
    chartFiles = sort(sf('get',chartIds,'chart.chartFileNumber')'); %#ok<UDIM>
    failedChartFiles = sort(chartFiles);
else
    failed = sort(verify_eml_resolved_functions(targetId,resolvedFunctions));
    failedChartFiles = [];
    for i = 1:numel(failed)
       chartFiles = resolvedFunctions(failed(i)).chartFiles;
       for j = 1:numel(chartFiles)
           if binsearch(failedChartFiles,chartFiles(j)) == 0
               failedChartFiles = [failedChartFiles chartFiles(j)];
           end
       end
       failedChartFiles = unique(failedChartFiles);
    end
end

if ~isfield(rebuildMetaData.(targetName0).(machineName0), 'resolvedFunctionsInfo')
    rebuildMetaData.(targetName0).(machineName0).resolvedFunctionsInfo = [];
end 
if ~isfield(rebuildMetaData.(targetName0).(machineName0), 'rebuiltChartFiles')
    rebuildMetaData.(targetName0).(machineName0).rebuiltChartFiles = [];
end 
% Update information on which chart files needs a rebuild
rebuildMetaData.(targetName0).(machineName0).rebuildChartFiles = failedChartFiles;
sf('set',mainMachineId,'.eml.rebuildMetaData', rebuildMetaData);
ok = isempty(failedChartFiles);
