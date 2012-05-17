%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorsOccurred = construct_module(chart, instanceHandle, specialization, fileNameInfo)

% Copyright 2002-2010 The MathWorks, Inc.

global gTargetInfo gChartInfo gMachineInfo	

if nargin < 3
    specialization = '';
end

if nargin < 4
    fileNameInfo = [];
end

errorsOccurred= 0;

compute_chart_instance_var_names(chart, specialization);
compute_state_variable_names(chart, specialization);
compute_state_event_enums(chart);
mustExportChartFunctions = export_chart_functions(chart);
targetName = sf('get',gMachineInfo.parentTarget,'target.name');

cdrModuleInfo.chartId = chart;
cdrModuleInfo.instanceHandle = instanceHandle;
cdrModuleInfo.specialization = specialization;
cdrModuleInfo.codingMultiInstance = gTargetInfo.codingMultiInstance;
cdrModuleInfo.mustExportChartFunctions = mustExportChartFunctions;
cdrModuleInfo.chartInstanceTypedef = gChartInfo.chartInstanceTypedef;
cdrModuleInfo.chartInputDataTypedef = gChartInfo.chartInputDataTypedef;
cdrModuleInfo.chartOutputDataTypedef = gChartInfo.chartOutputDataTypedef;
cdrModuleInfo.chartInstanceArgumentName = gChartInfo.chartInstanceArgumentName;
cdrModuleInfo.chartInputDataArgumentName = gChartInfo.chartInputDataArgumentName;
cdrModuleInfo.chartOutputDataArgumentName = gChartInfo.chartOutputDataArgumentName;
cdrModuleInfo.codingNoInitializer = gTargetInfo.codingNoInitializer;
if(gTargetInfo.codingRTW)
    cdrModuleInfo.codingSharedUtils = gTargetInfo.rtwProps.sharedUtilsEnabled;
    cdrModuleInfo.usedTargetFunctionLib = gTargetInfo.rtwProps.usedTargetFunctionLib;
    % Use the TFL control object attached to the model for TFL replacements.
    % Pass this handle into construct module.
    cdrModuleInfo.usedTargetFunctionLibH = get_param(gMachineInfo.mainMachineName, 'TargetFcnLibHandle');
elseif gTargetInfo.codingSFunction
    cdrModuleInfo.codingSharedUtils = false;
    cdrModuleInfo.usedTargetFunctionLib = 'NULL';
    cdrModuleInfo.usedTargetFunctionLibH = get_param(gMachineInfo.mainMachineName, 'SimTargetFcnLibHandle');
    tfl_recording('start',cdrModuleInfo.usedTargetFunctionLibH);
else
    cdrModuleInfo.codingSharedUtils = false;
    cdrModuleInfo.usedTargetFunctionLib = 'NULL';
    cdrModuleInfo.usedTargetFunctionLibH = 0;
end

try
    sf('Cg','construct_module',cdrModuleInfo);
catch ME 
    disp(ME.message);
    errorsOccurred = 1;
    sf('Private','coder_error_count_man','add',1);
    sf('Cg','destroy_module',chart);
    if gTargetInfo.codingSFunction
        tfl_recording('stop',cdrModuleInfo.usedTargetFunctionLibH);
    end
    return;
end
if(sf('feature', 'EMLActionLangInfrastructure') == 1)
    compute_implicit_event_information();
end

if gTargetInfo.codingSFunction
    tfl_recording('stop',cdrModuleInfo.usedTargetFunctionLibH);
end
collect_chart_aux_dependencies(chart, cdrModuleInfo, fileNameInfo);

if(strcmp(targetName,'testgen') && gTargetInfo.codingForAutoVerifier)
    % WISH: This is a temporary hack for Bill to do his testgen
    % work. MUST GET RID OF IT AS SOON AS POSSIBLE!!!!!!!
    if exist('slavt_gateway.m','file')
        try
           slavt_gateway('chart_analyze',chart,true);
        catch ME
          disp(ME.message);
        end
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect the TFL and EML auxiliary build dependency info
function collect_chart_aux_dependencies(chartId, cdrModuleInfo, fileNameInfo)
global gTargetInfo	

% Get the EML aux buildinfo for the chart
auxInfo = sf('Cg','get_recorded_eml_buildinfo',chartId);

if gTargetInfo.codingSFunction
    % Get the TFL usage for the specified chartId. The TFL usage is
    % the 'recorded' usage, i.e., the per-chart usage. There is
    % currently no single API function to retrieve this data, so we
    % must iterate over the TFL controller's hit cache.
    tflControl = cdrModuleInfo.usedTargetFunctionLibH;
    if ~isempty(fileNameInfo)
        tflControl.runFcnImpCallbacks(cdrModuleInfo.specialization, [], fileNameInfo.targetDirName);
    end
    hitCache = tflControl.HitCache;
    numEnts = length(hitCache);
    S = @(name) struct('FileName',name,'FilePath','','Group','TFL');
    P = @(path) struct('FilePath',path,'Group','TFL');
    for idx = 1:numEnts
        if hitCache(idx).RecordedUsageCount ~= 0
            hit = hitCache(idx);
            name = hit.Implementation.SourceFile;
            if ~isempty(name)
                auxInfo.sourceFiles(end+1) = S(name);
            end
            for i = 1:numel(hit.AdditionalSourceFiles)
                name = hit.AdditionalSourceFiles{i};
                if ~isempty(name)
                    auxInfo.sourceFiles(end+1) = S(name);
                end
            end
            for i = 1:numel(hit.AdditionalHeaderFiles)
                name = hit.AdditionalHeaderFiles{i};
                if ~isempty(name)
                    auxInfo.includeFiles(end+1) = S(name);
                end
            end
            for i = 1:numel(hit.AdditionalIncludePaths)
                name = hit.AdditionalIncludePaths{i};
                if ~isempty(name)
                    auxInfo.includePaths(end+1) = P(name);
                end
            end
            for i = 1:numel(hit.AdditionalLinkObjs)
                name = hit.AdditionalLinkObjs{i};
                if ~isempty(name)
                    auxInfo.linkObjects(end+1) = S(name);
                end
            end  
            for i = 1:numel(hit.AdditionalLinkFlags)
                name = hit.AdditionalLinkFlags{i};
                if ~isempty(name)
                    auxInfo.linkFlags(end+1) = S(name);
                end
            end                        
        end
    end
end

sfprivate('auxInfoChartCache','set',chartId,auxInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tfl_recording(method,tfl)
switch(method)
case 'start'
   % Indicate to the TFL that TLC will not be invoked. This prevents TFL entries that
   % contain TLC code gen callbacks from being used as replacements. Also, start recording
   % TFL replacements. This is needed so that we can ensure the correct (minimal) set of header
   % files is included into the chart source file.
   tfl.TLCSupported = false;
   tfl.Recording = true;
case 'stop'
   % stop recording as we are done with the codegen for this chart
   tfl.TLCSupported = true;
   tfl.Recording = false;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_chart_instance_var_names(chart, specialization)

global gTargetInfo gChartInfo

chartUniqueName = sf('CodegenNameOf',chart,specialization);

if(gTargetInfo.codingRTW)
   gChartInfo.chartInstanceTypedef  = '';
   gChartInfo.chartInstanceArgumentName = '';
else
   gChartInfo.chartInstanceTypedef  = ['SF',chartUniqueName,'InstanceStruct'];
   gChartInfo.chartInstanceArgumentName = 'chartInstance';
end
gChartInfo.chartInputDataTypedef = ['SF',chartUniqueName,'InputDataStruct'];
gChartInfo.chartOutputDataTypedef = ['SF',chartUniqueName,'OutputDataStruct'];
gChartInfo.chartInputDataArgumentName = 'chartInputData';
gChartInfo.chartOutputDataArgumentName = 'chartOutputData';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_state_variable_names(chart, specialization)

global gChartInfo


for state = [chart,gChartInfo.states]
    uniqStateName = sf('CodegenNameOf',state,specialization);
    if(state==chart || sf('get',state,'state.type')==1)
        % chart, AND states get their own bit
        fieldName = ['is_active_',uniqStateName];
        sf('set',state,'.unique.isActive',fieldName);
    else
        % optimize it away
        sf('set',state,'.unique.isActive','');
    end
    subStates = sf('SubstatesOf',state);
    if(~isempty(subStates))
        switch sf('get',state,'.decomposition')
            case 0  % CLUSTER_STATE
                fieldName = ['is_',uniqStateName];
                sf('set',state,'.unique.activeChild',fieldName);
                if sf('get',state,'.history');
                    fieldName = ['was_',uniqStateName];
                    sf('set',state,'.unique.prevActiveChild',fieldName);
                end
            case 1  % SET_STATE
            otherwise,
                construct_coder_error(state,'Bad decomposition');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_state_event_enums(chart)
  global gMachineInfo gChartInfo


  if(~isempty(gChartInfo.chartEvents))
    chartEventNumbers = sf('get',gChartInfo.chartEvents,'event.number')+gMachineInfo.machineEventThreshold;
      sf('set',gChartInfo.chartEvents,'event.number',chartEventNumbers);
  end

  file = ''; % Dummy argument, not used in the functions

  compute_event_enum_values(chart,file,1);
  compute_state_enums(file,chart);

  return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_implicit_event_information()
    global gMachineInfo gChartInfo

	gChartInfo.statesWithEntryEvent = sf('find',gChartInfo.states,'state.hasEntryEvent',1);
	gChartInfo.statesWithExitEvent = sf('find',gChartInfo.states,'state.hasExitEvent',1);
	gChartInfo.dataWithChangeEvent = sf('find',gChartInfo.chartData,'data.hasChangeEvent',1);

    % Machine-level explicit or implicit events are not supported; so there is no need to account
    % for them.
    gChartInfo.dataChangeEventThreshold = 0;
	if(~isempty(gChartInfo.chartEvents))
		gChartInfo.dataChangeEventThreshold = max(sf('get',gChartInfo.chartEvents,'event.number'))+1;
	end
	gChartInfo.stateEntryEventThreshold = gChartInfo.dataChangeEventThreshold + length(gChartInfo.dataWithChangeEvent);	
	gChartInfo.stateExitEventThreshold = gChartInfo.stateEntryEventThreshold + length(gChartInfo.statesWithEntryEvent);;
	
    return;
