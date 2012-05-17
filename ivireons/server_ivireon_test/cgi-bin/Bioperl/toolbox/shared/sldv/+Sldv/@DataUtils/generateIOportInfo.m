function [InputPortInfo, OutputPortInfo, flatInfo] = ...
    generateIOportInfo(model, parameterSettings)

%   Copyright 2008-2010 The MathWorks, Inc.

    if nargin<2
        parameterSettings.('StrictBusMsg') = ...
            struct('newvalue','ErrorLevel1','originalvalue','');
    end
        
    [inportCompInfo, outportCompInfo, modelCompileInfo] = ...
        Sldv.DataUtils.getModelCompiledIOInfo(model, parameterSettings);    
    
    flatInfo.InportCompInfo = inportCompInfo;
    flatInfo.OutportCompInfo = outportCompInfo;
    flatInfo.SampleTimes = modelCompileInfo.sampleTime;
    flatInfo.ModelSampleTimesDetails = modelCompileInfo.modelSampleDetails;    
               
    numInPorts  = length(inportCompInfo);
    InputPortInfo = cell(1, numInPorts);
    for idx = 1:numInPorts       
        InputPortInfo{idx} = genPortInfo(inportCompInfo(idx),false);
    end
    
    numOutPorts  = length(outportCompInfo);
    OutputPortInfo = cell(1, numOutPorts);
    for idx = 1:numOutPorts       
        OutputPortInfo{idx} = genPortInfo(outportCompInfo(idx),true);
    end            
end

function portInfo = genPortInfo(portInfoData, isOutport)    
    if ~portInfoData.IsStructBus
        if ~portInfoData.IsStruct
            leafportInfo = getLeafPortInfo(portInfoData,1);
            if isOutport && portInfoData.IsVirtualBus
                rootBusInfo = struct('BlockPath',leafportInfo.BlockPath,...
                                 'SignalName',leafportInfo.SignalName,...
                                 'BusObject','',...
                                 'SignalPath',leafportInfo.SignalLabels);   
                leafportInfo = rmfield(leafportInfo,{'BlockPath','SignalName'});
                portInfo{1} = rootBusInfo; 
                portInfo{end+1} = leafportInfo;            
            else
                portInfo = leafportInfo;
            end
        else
            depth = 1;     
            leafIdx = 1;
            leafSignalPaths = {portInfoData.compiledInfo.SignalPath};
            signalNames = sldvshareprivate('util_get_signal_parts',leafSignalPaths);
            signalPaths = signalNames(:); 
            portInfo = genCombinedLeafPortInfoStruct(signalPaths,depth,portInfoData,leafIdx,isOutport);                
        end
    else
        depth = 1;     
        leafIdx = 1;
        leafSignalPaths = {portInfoData.compiledInfo.SignalPath};
        signalNames = sldvshareprivate('util_get_signal_parts',leafSignalPaths);
        signalPaths = signalNames(:); 
        portInfo = genCombinedLeafPortInfo(signalPaths, depth,portInfoData,leafIdx,isOutport);    
    end    
    if isfield(portInfoData,'CompiledBusType') && isfield(portInfoData,'SignalHierarchy')
        if ~iscell(portInfo)
            portInfo.CompiledBusType = portInfoData.CompiledBusType;
            portInfo.SignalHierarchy = portInfoData.SignalHierarchy;
        else
            portInfo{1}.CompiledBusType = portInfoData.CompiledBusType;
            portInfo{1}.SignalHierarchy = portInfoData.SignalHierarchy;
        end
    end
end

function [portInfo,leafIdx] = genCombinedLeafPortInfo(signalPaths, depth,portInfoData,leafIdx,isOutport)
    portInfo = {};
    leafSignalPath = signalPaths(1);
    currDepthSigPath = leafSignalPath{1}{1};
    for i = 2:depth
        currDepthSigPath = strcat(currDepthSigPath, '.',leafSignalPath{1}{i}); 
    end
    
    leafBusObjPath = portInfoData.compiledInfo(leafIdx).BusObjPath;       
    busNames = sldvshareprivate('util_get_signal_parts',leafBusObjPath);
        
    if depth==1 && leafIdx==1
        rootBusInfo = struct('BlockPath',portInfoData.BlockPath,...
                             'SignalName',portInfoData.SignalName,...
                             'BusObject',busNames(depth),...
                             'SignalPath',currDepthSigPath);
    else
        rootBusInfo = struct('BusObject',busNames(depth),...
                             'SignalPath',currDepthSigPath);
    end
    
    % The signal to the output port can be a virtual or non-virtual
    % signal and Output port may not specify the BusObject. In this
    % case we can not understand whether Output port takes a virtual or
    % non-virtual signal unless you check CompiledBusStruct on the portH. 
    % Checking CompiledBusStruct on the Outports taking a bus signal is
    % costly because it requires StrictBusMsg to be set to error.
    % Therefore, don't use the IsVirtualBus info for bus Outports. We
    % really don't know it is really virtual or not. 
    % (We don't want to check CompiledBusStruct to really know
    % that it is a virtual or non-virtual bus). -DNA
    if depth==1 && ~isOutport
        rootBusInfo.IsVirtualBus = portInfoData.IsVirtualBus;
    end
   
    portInfo{1} = rootBusInfo;
   
    currentSigPaths = {};
    currSignalPrefix = '';
    for i=1:length(signalPaths)
        currentDepth = length(signalPaths{i})-1;
        if currentDepth==depth
            if ~isempty(currentSigPaths)
                [portInfo{end+1},leafIdx] = genCombinedLeafPortInfo(currentSigPaths, depth+1,portInfoData,leafIdx,isOutport); %#ok<AGROW>
                currentSigPaths = {};
                currSignalPrefix = '';
            end
            portInfo{end+1} = getLeafPortInfo(portInfoData,leafIdx); %#ok<AGROW>
            leafIdx = leafIdx+1;
        else
            nextSigPrefix = signalPaths{i}{depth+1};
            if ~strcmp(nextSigPrefix,currSignalPrefix)
                currSignalPrefix = nextSigPrefix;                
                if ~isempty(currentSigPaths)
                    [portInfo{end+1},leafIdx] = genCombinedLeafPortInfo(currentSigPaths, depth+1,portInfoData,leafIdx,isOutport); %#ok<AGROW>
                    currentSigPaths = {};
                end
            end            
            currentSigPaths{end+1} = signalPaths{i};          %#ok<AGROW>
        end                 
    end        
    if ~isempty(currentSigPaths)
        [portInfo{end+1},leafIdx] = genCombinedLeafPortInfo(currentSigPaths, depth+1,portInfoData,leafIdx,isOutport);
    end
end

function [portInfo,leafIdx] = genCombinedLeafPortInfoStruct(signalPaths,depth,portInfoData,leafIdx,isOutport)
    portInfo = {};
    leafSignalPath = signalPaths(1);
    currDepthSigPath = leafSignalPath{1}{1};
    for i = 2:depth
        currDepthSigPath = strcat(currDepthSigPath, '.',leafSignalPath{1}{i}); 
    end
       
    structObjPath = portInfoData.compiledInfo(leafIdx).StructObjPath;                      
        
    if depth==1 && leafIdx==1
        rootBusInfo = struct('BlockPath',portInfoData.BlockPath,...
                             'SignalName',portInfoData.SignalName,...
                             'StructObject',structObjPath,...
                             'SignalPath',currDepthSigPath);
    else
        rootBusInfo = struct('StructObject',structObjPath,...
                             'SignalPath',currDepthSigPath);
    end
           
    rootBusInfo.IsVirtualBus = false;
   
    portInfo{1} = rootBusInfo;
   
    currentSigPaths = {};
    currSignalPrefix = '';
    for i=1:length(signalPaths)
        currentDepth = length(signalPaths{i})-1;
        if currentDepth==depth
            if ~isempty(currentSigPaths)
                [portInfo{end+1},leafIdx] = genCombinedLeafPortInfoStruct(currentSigPaths, depth+1,portInfoData,leafIdx,isOutport); %#ok<AGROW>
                currentSigPaths = {};
                currSignalPrefix = '';
            end
            portInfo{end+1} = getLeafPortInfo(portInfoData,leafIdx); %#ok<AGROW>
            leafIdx = leafIdx+1;
        else
            nextSigPrefix = signalPaths{i}{depth+1};
            if ~strcmp(nextSigPrefix,currSignalPrefix)
                currSignalPrefix = nextSigPrefix;                
                if ~isempty(currentSigPaths)
                    [portInfo{end+1},leafIdx] = genCombinedLeafPortInfoStruct(currentSigPaths, depth+1,portInfoData,leafIdx,isOutport); %#ok<AGROW>
                    currentSigPaths = {};
                end
            end            
            currentSigPaths{end+1} = signalPaths{i};          %#ok<AGROW>
        end                 
    end        
    if ~isempty(currentSigPaths)
        [portInfo{end+1},leafIdx] = genCombinedLeafPortInfoStruct(currentSigPaths, depth+1,portInfoData,leafIdx,isOutport);
    end
end

function leafPortInfo = getLeafPortInfo(portInfoData,leafeIdx)        
    if leafeIdx==1 && ~portInfoData.IsStructBus  && ~portInfoData.IsStruct
        leafPortInfo.BlockPath = portInfoData.BlockPath;
        leafPortInfo.SignalName = portInfoData.SignalName;
    end
    leafPortInfo.Dimensions = portInfoData.compiledInfo(leafeIdx).Dimensions;
    leafPortInfo.DataType = portInfoData.compiledInfo(leafeIdx).DataType;
    leafPortInfo.Complexity = portInfoData.compiledInfo(leafeIdx).Complexity;
    leafPortInfo.SampleTimeStr = portInfoData.SampleTimeStr;
    if portInfoData.IsStructBus
        leafPortInfo.SampleTime = portInfoData.compiledInfo(leafeIdx).SampleTime;
        leafPortInfo.ParentSampleTime = portInfoData.SampleTime;
    else
        leafPortInfo.SampleTime = portInfoData.SampleTime;
        leafPortInfo.ParentSampleTime = portInfoData.SampleTime;            
    end        
    leafPortInfo.SignalLabels = portInfoData.compiledInfo(leafeIdx).SignalPath;         
    leafPortInfo.Used = portInfoData.compiledInfo(leafeIdx).Used;
end