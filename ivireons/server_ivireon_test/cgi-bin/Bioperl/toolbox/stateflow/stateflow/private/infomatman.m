function infoStruct = infomatman(loadOrSave,modelOrBinary,machineIdOrName,mainMachineIdOrName,targetIdOrName,dateNum)
% initialize infoStruct

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.26.4.36 $  $Date: 2010/05/20 03:36:10 $

switch(loadOrSave)
    case {'clearcache','getcache'}
        % this is a special call to manage the cache of infoStructs
        % see the body of load_method for more info on it
        infoStruct = load_method(loadOrSave);
        return;
end

if(nargin<6)
    dateNum = 0;
end

if isunix
    fileSepChar = '/';
else
    fileSepChar = '\';
end
if(isa(machineIdOrName,'numeric'))
    machineId = machineIdOrName;
    machineName = sf('get',machineId,'machine.name');
else
    machineName = machineIdOrName;
    machineId = sf('find','all','machine.name',machineName);
end
if(isa(mainMachineIdOrName,'numeric'))
    mainMachineName = sf('get',mainMachineIdOrName,'machine.name');
    mainMachineId = mainMachineIdOrName;
else
    mainMachineName = mainMachineIdOrName;
    mainMachineId = sf('find','all','machine.name',mainMachineName);
end
if(isa(targetIdOrName,'numeric'))
    targetId = targetIdOrName;
    targetName = sf('get',targetId,'target.name');
else
    targetName = targetIdOrName;
    if(~isempty(machineId))
        targetId = sf('find',sf('TargetsOf',machineId),'target.name',targetName);
    else
        targetId = [];
    end
end


switch(modelOrBinary)
case 'binary'
    [binaryInfoDirectory,projectDirArray] = get_sf_proj(pwd,mainMachineName,machineName,targetName,'info');
    binaryInfoMatFileName = [binaryInfoDirectory,fileSepChar,'binfo.mat'];
    switch(loadOrSave)
    case 'load'
        infoStruct = load_method(binaryInfoMatFileName);
    case 'save'
        %%% note that we do NOT calculate the target checksum
        %%% since this is called after a successful build
        create_directory_path(projectDirArray{:});
        save_method(binaryInfoMatFileName,mainMachineId,machineId,targetId,targetName,dateNum);
    end
case 'dll'
    [infoStruct.machineChecksum,infoStruct.date] = get_checksum_from_dll(mainMachineName,'machine');
    infoStruct.machineChartChecksum = []; % WISH: fix this.
    infoStruct.targetChecksum = get_checksum_from_dll(mainMachineName,'target');
    infoStruct.makefileChecksum = get_checksum_from_dll(mainMachineName,'makefile');
    infoStruct.exportedFcnChecksum = get_checksum_from_dll(mainMachineName,'exportedFcn');

    chartIds = get_instantiated_charts_in_machine(machineId);
    chartFileNumbers = sf('get',chartIds,'chart.chartFileNumber');
    sortedFileNumbers = sort(chartFileNumbers);
    infoStruct.chartFileNumbers = sortedFileNumbers;
    infoStruct.chartChecksums = zeros(length(sortedFileNumbers),4);
    errorChecksum = 0;
    for i = 1:length(sortedFileNumbers)
        if(strcmp(mainMachineName,machineName))
            chksum = get_checksum_from_dll(mainMachineName,'chart','',sortedFileNumbers(i));
        else
            chksum = get_checksum_from_dll(mainMachineName,'library',machineName,sortedFileNumbers(i));
        end
        infoStruct.chartChecksums(i,:) = chksum;
        if (all(chksum(:) == 0))
            errorChecksum = 1;
        end
    end
    if errorChecksum
        infoStruct.sfunChecksum = [0 0 0 0];
    else
        if(strcmp(mainMachineName,machineName))
            infoStruct.sfunChecksum = get_checksum_from_dll(mainMachineName,'');
        else
            infoStruct.sfunChecksum = get_checksum_from_dll(mainMachineName,'library',machineName);
        end
    end
end

if strcmp(loadOrSave, 'load')
    invalid = false;
    n = numel(infoStruct.chartFileNumbers);
    infoStruct.forceRebuildChartFlags = zeros(1, n); % Due to eml resolved functions change
    rebuildMetaData = sf('get',mainMachineId,'.eml.rebuildMetaData');
    targetName0 = get_eml_metadata_target_name(targetName);
    machineName0 = get_eml_metadata_machine_name(machineName);
    if ~isempty(rebuildMetaData) && isfield(rebuildMetaData, targetName0) && isfield(rebuildMetaData.(targetName0), machineName0)
        for i = 1:n
            chartFileNumber = infoStruct.chartFileNumbers(i);
            rebuildChartFiles = rebuildMetaData.(targetName0).(machineName0).rebuildChartFiles;
            if binsearch(rebuildChartFiles, chartFileNumber) ~= 0
                infoStruct.chartChecksums(i,:) = zeros(1,4);
                infoStruct.forceRebuildChartFlags(i) = 1;
                invalid = true;
            end
        end
    end
    if invalid
        infoStruct.sfunChecksum = [0 0 0 0];
    end
end

function save_method(modelInfoMatFileName,mainMachineId,machineId,targetId,targetName,dateNum)

    oldInfoStruct = load_method(modelInfoMatFileName);

    chartIds = sf('get',machineId,'machine.charts');
    chartFileNumbers = sf('get',chartIds,'chart.chartFileNumber');

    dropCharts = [];
    for i = 1:length(chartIds)
        if ~sf('get', chartIds(i), 'chart.isInstantiated')
            if ~any(oldInfoStruct.chartFileNumbers == chartFileNumbers(i))
                dropCharts(end+1) = i; %#ok<AGROW>
            end
        end
    end
    chartIds(dropCharts) = [];
    chartFileNumbers(dropCharts) = [];

    [sortedFileNumbers,indices] = sort(chartFileNumbers);
    chartIds = chartIds(indices);

    infoStruct.date = dateNum;
    infoStruct.sfVersion = sf('Version',1);
    infoStruct.mVersion = version;

    infoStruct.chartFileNumbers = sortedFileNumbers;
    infoStruct.chartChecksums = sf('get',chartIds,'chart.checksum');
    infoStruct.makefileChecksum = sf('get',machineId,'machine.makefileChecksum');
    infoStruct.machineChecksum = sf('get',machineId,'machine.checksum');
    infoStruct.machineChartChecksum = sf('get',machineId,'machine.chartChecksum');
    infoStruct.targetChecksum = sf('get',targetId,'target.checksumSelf');
    infoStruct.sfunChecksum = sf('get',targetId,'target.checksumNew');
    rebuildMetaData = sf('get',mainMachineId,'.eml.rebuildMetaData');
    targetName0 = get_eml_metadata_target_name(targetName);
    machineName = sf('get',machineId,'machine.name');
    machineName0 = get_eml_metadata_machine_name(machineName);
    if ~isempty(rebuildMetaData) && isfield(rebuildMetaData, targetName0) && isfield(rebuildMetaData.(targetName0), machineName0)
        infoStruct.emlRebuildMetaData.(machineName0) = rebuildMetaData.(targetName0).(machineName0);
    end
    if strcmp(targetName,'rtw')
        % This logic is intended for non-coder-unified charts. Parameter
        % "operationReplacementOccurred" could have been changed in fixed
        % point lowering, so RTW target checksum has to be invalidated.
        % For coder-unified charts, all the magic happens in RTWCG.
        t = get_param(sf('get',machineId,'machine.name'), 'TargetFcnLibHandle');
        if t.operationReplacementOccurred
            infoStruct.targetChecksum = [0,0,0,0];
            infoStruct.sfunChecksum = [0,0,0,0];
        end
    end
    
    infoStruct.exportedFcnInfo = exported_fcns_in_machine(machineId);
    infoStruct.exportedFcnChecksum = sf('get',machineId,'machine.exportedFcnChecksum');

    if(sf('get',machineId,'machine.isLibrary'))
        infoStruct.isLibrary = 'Yes';
    else
        infoStruct.isLibrary = 'No';
    end
    if(strcmp(targetName,'sfun'))
        infoStruct.isDebug = target_code_flags('get',targetId,'debug');
    end

    if(sf('get',machineId,'machine.codeOptimizer.machineInlinable'))
        infoStruct.machineInlinable = 'Yes';
    else
        infoStruct.machineInlinable = 'No';
    end

    for i = 1:length(chartIds)
        indx = find(oldInfoStruct.chartFileNumbers==infoStruct.chartFileNumbers(i));
        if ~isempty(indx)
            oldChartInfo = oldInfoStruct.chartInfo(indx);
        else
            oldChartInfo = [];
        end
        if sf('get', chartIds(i), 'chart.codeGeneratedNow')
            sf('set', chartIds(i), 'chart.codeGeneratedNow', 0);
            if(strcmp(targetName,'rtw'))
                inputData = sf('find',sf('DataOf',chartIds(i)),'data.scope','INPUT_DATA');
                inputEvents = sf('find',sf('EventsOf',chartIds(i)),'event.scope','INPUT_EVENT');
                infoStruct.chartInfo(i).InputDataCount = sprintf('%d',length(inputData));
                infoStruct.chartInfo(i).InputEventCount = sprintf('%d',length(inputEvents));
                infoStruct.chartInfo(i).NoInputs = yes_or_no(isempty(inputData) & isempty(inputEvents));
                infoStruct.chartInfo(i).usesGlobalEventVar = sf('get',chartIds(i),'chart.rtwInfo.usesGlobalEventVar');                
                infoStruct.chartInfo(i).instanceInfo = sf('get', chartIds(i), 'chart.rtwInfo.instanceInfo');
            end
            [found lwBuildInfo] = auxInfoChartCache('get',chartIds(i));
            if ~found
                % This should not occur, since we've just built the chart.
                if ~isempty(oldChartInfo) && isfield(oldChartInfo, 'auxBuildInfo')
                    lwBuildInfo = oldChartInfo.auxBuildInfo;
                end
            end
            infoStruct.chartInfo(i).auxBuildInfo = lwBuildInfo;
            infoStruct.chartInfo(i).cgStats = sf('get',chartIds(i),'chart.cgStats');
            if strcmp(targetName,'sfun')
                infoStruct.chartInfo(i).autoinheritanceInfo = generate_autoinheritance_info(chartIds(i));
            end
        else
            if ~isempty(oldChartInfo)
                infoStruct.chartInfo(i) = oldChartInfo;
            end
        end
    end

    % Compute machine linkflags for simulation target
    if strcmp(targetName, 'sfun')
        linkFlags = {};
        for i = 1:length(chartIds)
            chartInfo = infoStruct.chartInfo(i);
            if isfield(chartInfo, 'auxBuildInfo') && ~isempty(chartInfo.auxBuildInfo)
                if ~isempty(chartInfo.auxBuildInfo.linkFlags)
                    flags = {chartInfo.auxBuildInfo.linkFlags(:).Flags};
                    linkFlags = [linkFlags flags]; %#ok<AGROW>
                end
            end
        end

        % For main machine, collect all link flags needed for link machines
        if machineId == mainMachineId
            linkMachines = get_link_machine_list(mainMachineId, 'sfun');
            for i = 1:length(linkMachines)
                linkInfoStruct = infomatman('load', 'binary', linkMachines{i}, mainMachineId, 'sfun');
                if isfield(linkInfoStruct, 'linkFlags') && ~isempty(linkInfoStruct.linkFlags)
                    linkFlags = [linkFlags linkInfoStruct.linkFlags]; %#ok<AGROW>
                end
            end
        end
        
        infoStruct.linkFlags = unique(linkFlags);
    end

    if(strcmp(targetName,'rtw'))
        infoStruct.machineTLCFile = sf('get',machineId,'machine.rtwInfo.machineTLCFile');
        infoStruct.machineDataVarInfo = sf('get', machineId, 'machine.rtwInfo.machineDataVarInfo');
    end
    infoStruct.time = sf('get',targetId,'target.time');

    save(modelInfoMatFileName,'infoStruct');
    auxInfoChartCache('clr',chartIds);
    
function ai = generate_autoinheritance_info(chartId)
	chartParentedData = sf('DataOf',chartId);

    ai.checksum = sf('SyncAutoinheritanceChecksum', chartId);

    ai.inputs = get_ai_for_scope(chartParentedData, 'INPUT_DATA');
	ai.parameters = get_ai_for_scope(chartParentedData, 'PARAMETER_DATA');
	ai.outputs = get_ai_for_scope(chartParentedData, 'OUTPUT_DATA');


function ai = get_ai_for_scope(dataSet, dataScope)
    dataSubset =  sf('find',dataSet,'data.scope',dataScope);
    
    ai = [];
    
    for i = 1:length(dataSubset)
        data = dataSubset(i);
        dataParsedInfo = sf('DataParsedInfo', data);

        dataSize = dataParsedInfo.size;
        while (length(dataSize)<2)
            dataSize(end+1) = 1; %#ok<AGROW>
        end
        ai(i).size = dataSize; %#ok<AGROW>
        
        ai(i).type.base = dataParsedInfo.type.base; %#ok<AGROW>

        ai(i).type.fixpt = dataParsedInfo.type.fixpt; %#ok<AGROW>
        
        ai(i).complexity = dataParsedInfo.complexity; %#ok<AGROW>
    end
    

function infoStruct = load_method(infoMatFileName)

    % G403338: Turns out that these mat files get loaded
    % hundreds of times during an RTW build for models
    % with many charts potentially causing severe slowdowns.
    % We now implement a caching scheme (robust to time-stamp changes)
    % so that we only load the ones we need once per codegen session
    % At the time of compilation end (compile_fail or compile_pass)
    % callbacks, we issue a clear command from slsf.m to make sure
    % this cache doesn't stay in memory forever.
    %
    persistent sInfoStructCacheList;
    persistent sCacheStats
    
    switch(infoMatFileName)
        case 'clearcache'
            sInfoStructCacheList = [];
            infoStruct = sCacheStats; % return the stats before clearing
            sCacheStats = [];
            eml_report_manager('clearcache');
            return;
        case 'getcache'
            infoStruct = sInfoStructCacheList;
            return;
        case 'getcachestats'
            infoStruct = sCacheStats;
            return;
    end

    if(isempty(sCacheStats))
        sCacheStats.hits = 0;
        sCacheStats.misses = 0;
    end
    
    if(isempty(infoMatFileName) || ~exist(infoMatFileName,'file'))
        infoStruct = get_default_info_struct;
        return;
    end

    if(0)
        infoStruct = force_load_info_mat_file(infoMatFileName);
        return;
    end
    infoStructCache.fileName = infoMatFileName;
    fileDirInfo = dir(infoStructCache.fileName);
    infoStructCache.dateNum = fileDirInfo.datenum;
    infoStructCache.infoStruct = [];

    inCache = false;
    if(~isempty(sInfoStructCacheList))
       cacheIndex = find(strcmp({sInfoStructCacheList.fileName},infoMatFileName));
       if(isempty(cacheIndex))
            cacheIndex = length(sInfoStructCacheList)+1;
       else
           inCache = true;
       end
    else
        cacheIndex = 1;
    end

    if(~inCache)
        sCacheStats.misses = sCacheStats.misses+1;
        infoStructCache.infoStruct = force_load_info_mat_file(infoMatFileName);
    else
        if(sInfoStructCacheList(cacheIndex).dateNum<infoStructCache.dateNum)
            sCacheStats.misses = sCacheStats.misses+1;
            infoStructCache.infoStruct = force_load_info_mat_file(infoMatFileName);
        else
            sCacheStats.hits = sCacheStats.hits+1;
            infoStructCache.infoStruct = sInfoStructCacheList(cacheIndex).infoStruct;
        end                            
    end
    if(isempty(sInfoStructCacheList))
        sInfoStructCacheList = infoStructCache;
    else
        sInfoStructCacheList(cacheIndex) = infoStructCache;
    end
    infoStruct = infoStructCache.infoStruct;
        
        
function infoStruct = force_load_info_mat_file(infoMatFileName)
    % Be robust to corrupted MAT files and do the default thing
    % G127858
    try
        load(infoMatFileName);
    catch ME %#ok<NASGU>
        infoStruct = get_default_info_struct;
    end

function infoStruct = get_default_info_struct
    infoStruct.date = 0.0;
    infoStruct.sfVersion = 0.0;
    infoStruct.mVersion = 0.0;
    infoStruct.machineChecksum = [];
    infoStruct.machineChartChecksum = [];
    infoStruct.targetChecksum = [];
    infoStruct.makefileChecksum = [];
    infoStruct.chartFileNumbers = [];
    infoStruct.chartChecksums = [];
    infoStruct.chartTLCFiles = {};
    infoStruct.machineTLCFile = [];
    infoStruct.machineInlinable = 'No';
    infoStruct.sfunChecksum = [];
    infoStruct.exportedFcnInfo = [];
    infoStruct.exportedFcnChecksum = [];
    infoStruct.chartReusableOutputs = [];
    infoStruct.chartExpressionableInputs = [];

function y_or_n = yes_or_no(val)
    if val
        y_or_n = 'Yes';
    else
        y_or_n = 'No';
    end
