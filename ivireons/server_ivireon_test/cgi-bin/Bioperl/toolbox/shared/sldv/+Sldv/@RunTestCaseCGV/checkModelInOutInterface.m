function checkModelInOutInterface(obj)
    % Model was closed load it

%   Copyright 2010 The MathWorks, Inc.

    obj.configureAutoSaveState;
    
    obj.cacheBaseWorkspaceVars;
      
    obj.checkSldvData;
    
    obj.convertSldvDataToTimeSeries;
    
    obj.findBaseWSSimulinkParameters;
    
    obj.FunTs = ...
            sldvshareprivate('mdl_derive_sampletime_for_sldvdata',...
            obj.SldvData.AnalysisInformation.SampleTimes);
        
    [obj.InportBlkHs, obj.OutportBlkHs] = ...
            Sldv.utils.getSubSystemPortBlks(obj.ModelH);
        
    msgLoggedId = 'NoSignalNameOutport';
    msgLoggedCore = xlate(['Signals connecting to Outports can be logged ' ...
                'in TimeSeries format only if they are named. Signals ' ...
                'connected the following Outports are not named:' char(10)]);                
    msgLoggedBlocks = {};                   
    if strcmp(obj.OutputFormat,'TimeSeries')        
        portHandles = Sldv.utils.getSubsystemIOPortHs([], obj.OutportBlkHs);        
        for idx=1:length(obj.OutportBlkHs)                            
            lineH = get_param(portHandles(idx),'Line');                                    
            if isempty(get_param(lineH,'Name'))           
                msgLoggedBlocks{end+1} = getfullname(obj.OutportBlkHs(idx));     %#ok<AGROW>
                msgLoggedCore = [msgLoggedCore '''%s''' char(10)]; %#ok<AGROW>
            end
        end
    end    
    if ~isempty(msgLoggedBlocks)
        msgLoggedCore = sprintf(msgLoggedCore,msgLoggedBlocks{:});
        obj.reportModelInOutIncompatiblity(...
            msgLoggedCore, msgLoggedId);
    end        
    
    msgBusStructId = 'BusOutputAsStructOutport';
    msgBusStruct = xlate(['The ''Output as non-virtual bus in parent model'' parameter ' ...
        'must be checked for Outport blocks specifying properties via bus objects.' ...
        'Following Outport blocks do not satisfy this condition:' char(10)]); 
    msgBusStructBlocks = {};    
    OutputPortInfo = obj.SldvData.AnalysisInformation.OutputPortInfo;    
    for idx=1:length(OutputPortInfo)
        outportInfo = OutputPortInfo{idx};
        if iscell(outportInfo) && ...
                Sldv.utils.isInOutportBlkDataTypeBus(obj.OutportBlkHs(idx)) && ...
                strcmp(get_param(obj.OutportBlkHs(idx),'BusOutputAsStruct'),'off')  
            msgBusStructBlocks{end+1} = getfullname(obj.OutportBlkHs(idx));     %#ok<AGROW>
            msgBusStruct = [msgBusStruct '''%s''' char(10)]; %#ok<AGROW>                                                
        end               
    end
    if ~isempty(msgBusStructBlocks)
        msgBusStruct = sprintf(msgBusStruct,msgBusStructBlocks{:});
        obj.reportModelInOutIncompatiblity(...
            msgBusStruct, msgBusStructId);
    end   
    
    msgSignalLoggingId = 'NoSignalLoggingOutport';
    msgSignalLogging = xlate(['Signals connecting to Outports can be logged ' ...
        'in TimeSeries format only if signal logging is enabled. ' ...        
        'Signal logging is not enabled on the signal that are ' ...
        'connected to the following blocks:' char(10)]);    
    msgSignalLoggingBlocks = {};    
    obj.derivePortHandlesToLog;
    numPorts = length(obj.PortHsToLog);    
    for idx=1:numPorts        
        if strcmp(get_param(obj.PortHsToLog(idx),'DataLogging'),'off')                        
            msgSignalLoggingBlocks{end+1} = getfullname(get_param(obj.PortHsToLog(idx),'Parent'));     %#ok<AGROW>
            msgSignalLogging = [msgSignalLogging '''%s''' char(10)]; %#ok<AGROW>                                           
        end
    end
    if ~isempty(msgSignalLoggingBlocks)
        msgSignalLogging = sprintf(msgSignalLogging,msgSignalLoggingBlocks{:});
        obj.reportModelInOutIncompatiblity(...
            msgSignalLogging, msgSignalLoggingId);
    end
    
    msgNoInterpId = 'InterpolatedInport';
    msgNoInterp = xlate(['The ''Interpolate data'' parameter should not be checked ' ...
        'for Inport blocks with double, single, fixed-point and enumerated data types. ' ...                
        '''Interpolate data'' is checked for following Inport blocks:' char(10)]); 
    msgNoInterpBlocks = {};
    inputPortInfo = obj.SldvData.AnalysisInformation.InputPortInfo;
    numIports = length(inputPortInfo);
    for idx=1:numIports
        if strcmp(get_param(obj.InportBlkHs(idx),'Interpolate'),'on') && ...
                Sldv.RunTestCase.nointerpDataType(inputPortInfo{idx})    
            msgNoInterpBlocks{end+1} = getfullname(obj.InportBlkHs(idx));     %#ok<AGROW>
            msgNoInterp = [msgNoInterp '''%s''' char(10)]; %#ok<AGROW>                                         
        end
    end
    if ~isempty(msgNoInterpBlocks)
        msgNoInterp = sprintf(msgNoInterp,msgNoInterpBlocks{:});
        obj.reportModelInOutIncompatiblity(...
            msgNoInterp, msgNoInterpId);
    end
end
% LocalWords:  sampletime sldvdata
