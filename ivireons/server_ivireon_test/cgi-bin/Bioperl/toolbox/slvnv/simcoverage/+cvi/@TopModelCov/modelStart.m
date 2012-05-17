
%   Copyright 2008 The MathWorks, Inc.

function modelStart(modelH)
try
    
% in case of strcmpi(get_param(modelH,'compileForCoverageInProgress'),'on')
% testId can be 0!!
updateModelinfo(modelH);
reconnectAtomicSubchartAndSlinSF(modelH);
cv('compareCheckSum',modelH);
cv('allocateModelCoverageData',modelH);
coveng = cvi.TopModelCov.getInstance(modelH);
 if coveng.isLastReporting(modelH)  &&  ~isempty(coveng.scriptDataMap) 
     scriptStart(coveng, modelH);
 end
 
catch MEx
    rethrow(MEx);
end
%==========================================    
%reconnect the atomic subchart form it's subsystem to the reffering state
function reconnectAtomicSubchartAndSlinSF(modelH)

    covId = get_param(modelH, 'CoverageId');
    topCvId = cv('get',cv('get',covId,'.activeRoot'),'.topSlsf');
    chartSubsysCvId2ChartCvId = containers.Map('KeyType', 'double', 'ValueType', 'any');
    chartCvIds  = findCharts(topCvId, chartSubsysCvId2ChartCvId);
    if ~isempty(chartCvIds)
        subsysCvIds = [];
        cvStateIds  = [];
        for j = 1:numel(chartCvIds)
            [cvStateIds subsysCvIds] =  findStateSubsysPairs(chartCvIds(j),cvStateIds, subsysCvIds);   
        end
        %reconnec them
        for idx = 1:numel(subsysCvIds)
            subsysCvId = subsysCvIds(idx);
            if chartSubsysCvId2ChartCvId.isKey(subsysCvId)
                subsysCvId = chartSubsysCvId2ChartCvId(subsysCvId);
            end
            cv('BlockAdoptChildren', cvStateIds(idx), subsysCvId);
        end
    end
%==========================================    

 function chartCvIds  = findCharts(topCvId, chartSubsysCvId2ChartCvId)
    mixedIds = cv('DecendentsOf', topCvId);
    allChartCvId  = cv('find',mixedIds, 'slsfobj.origin', 2, 'slsfobj.refClass', sf('get','default','chart.isa'));
    chartCvIds = [];
    for idx = 1:numel(allChartCvId)
        cvChartId = allChartCvId(idx);
        subsysCvId  = cv('get',cvChartId , '.treeNode.parent');
        sfSubsysHandle = cv('get', subsysCvId , '.handle');
        if  cv('get', topCvId, '.handle') == sfSubsysHandle %subsystem recording
             continue;
        end
         
        if ~sfprivate( 'is_eml_based_chart', cv('get', cvChartId, '.handle'))
            chartCvIds(end+1) = cvChartId;
            chartSubsysCvId2ChartCvId(subsysCvId) = cvChartId;
        end
    end
    

%==========================================    
function [cvStateIds subsysCvIds] =  findStateSubsysPairs(chartCvId,  cvStateIds, subsysCvIds)
    allcvIds = cv('DecendentsOf', chartCvId);
    allStateIds = cv('find',allcvIds, 'slsfobj.origin', 2, 'slsfobj.refClass', sf('get','default','state.isa'));
    for idx = 1:numel(allStateIds)
        cvid = allStateIds(idx);
        sfStateId = cv('get',cvid, '.handle');
        blockH = sf('get',sfStateId, '.simulink.blockHandle');
        if ishandle(blockH)
            subsysCvId = get_param(blockH, 'CoverageId'); %#ok<*AGROW>
            if  subsysCvId <= 0 % it is a library
                libBlockPath = getfullname(blockH);
                libChartPath = sf('FullNameOf', cv('get', chartCvId, '.handle'), '/');
                relBlockPath = libBlockPath(end-(numel(libBlockPath)- numel(libChartPath))+1:end);
                instancePath = cv('get',chartCvId, '.origPath');
                newBlockPath = [instancePath relBlockPath];
                subsysCvId = get_param(newBlockPath, 'CoverageId'); 
            end
            subsysCvIds(end+1) = subsysCvId;
            cvStateIds(end+1) = cvid; 
        end
    end

%==========================================    
function updateModelinfo(handle)

    testId =   cv('get',get_param(handle, 'CoverageId'),'.activeTest');
    if testId == 0
        return;
    end
    strParNames = {'modelVersion','creator','lastModifiedDate'};
    for pn = strParNames(:)'
        cv('set',testId,['.' pn{1}], get_param(handle, pn{1}));
    end
    
    cv('set',testId, '.inlineParams', strcmpi(get_param(handle, 'InlineParams'),'on'));
    cv('set',testId, '.conditionallyExecuteInputs', strcmpi(get_param(handle, 'conditionallyExecuteInputs'),'on'));
    
    status  = get_param(handle, 'BlockReduction');
    if strcmpi(status, 'on') && cv('get',testId, '.forceBlockReductionOff')
        status = 'forced off';
    end
    cv('set',testId, '.blockReductionStatus', status);
%====================
function scriptStart(coveng, modelH)

if ~isempty(coveng.scriptDataMap)
    reloadMachines = {};
    fields = fieldnames(coveng.scriptDataMap);
    for idx = 1:numel(fields)
        scriptName = fields{idx};
        oldRootId = coveng.scriptDataMap.(scriptName).oldRootId;
        cvScriptId = coveng.scriptDataMap.(scriptName).cvScriptId;
        modelcovId = cv('get',cvScriptId , '.modelcov');
        updateScriptinfo(cv('get',modelcovId,'.activeTest'), modelH, cvScriptId);
        cv('ScriptStart', modelcovId , oldRootId);
        if (oldRootId ~= 0)
            
            oldCvScriptId = cv('get',cv('get',cv('get',modelcovId,'.activeRoot'),'.topSlsf'),'.treeNode.child');
            if oldCvScriptId  ~= cvScriptId 
                coveng.scriptDataMap.(scriptName).cvScriptId = oldCvScriptId;
                machineIdStrs = coveng.scriptDataMap.(scriptName).machineIdStrs;
                for idx1 = 1:numel(machineIdStrs)
                    machineIdStr = machineIdStrs{idx1};
                    coveng.scriptNumToCvIdMap.(machineIdStr)(cv('get',oldCvScriptId ,'.refClass')+1) = oldCvScriptId ;
                    reloadMachines{end+1}  = machineIdStr; %#ok<AGROW>
                end
            end
        end
    end
    reload_old_script_ids(coveng, reloadMachines)
end
%==========================================    
function reload_old_script_ids(coveng, reloadMachines)

    for idx = 1:numel(reloadMachines)
        machineIdStr = reloadMachines{idx};
        numToCvIdMap = coveng.scriptNumToCvIdMap.(machineIdStr);
        machineId = str2double(machineIdStr(2:end)); 
        mainMachine = sf('get', machineId, '.mainMachine');
        if mainMachine ~= 0
            machineName = sf('get',mainMachine ,'.name'); 
        else
            machineName = sf('get',machineId,'.name'); 
        end
        sfunName =  [machineName  '_sfun'];
        feval(sfunName,'sf_debug_api','set_script_cv_ids', machineId, numToCvIdMap);    
    end
    
%==========================================    
function updateScriptinfo(testId, handle, cvScriptId)
    if testId == 0
        return;
    end
    scriptId = cv('get', cvScriptId, '.handle');
    fname = sf('get',scriptId, '.filePath');
    info = dir(fname);
    cv('set',testId,'.lastModifiedDate', info.date);
    
    cv('set',testId, '.inlineParams', strcmpi(get_param(handle, 'InlineParams'),'on'));
    cv('set',testId, '.blockReduction', strcmpi(get_param(handle, 'BlockReduction'),'on'));
    cv('set',testId, '.conditionallyExecuteInputs', strcmpi(get_param(handle, 'conditionallyExecuteInputs'),'on'));


 