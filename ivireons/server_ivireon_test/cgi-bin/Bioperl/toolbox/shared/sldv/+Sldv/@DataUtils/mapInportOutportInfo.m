function sldvDataMapped = mapInportOutportInfo(sldvData)

%   Copyright 2009 The MathWorks, Inc.

    sldvDataMapped = sldvData;
    modelInformation = sldvDataMapped.ModelInformation;  
    % ReplacementModel field will be on the ModelInformation
    % if block replacements are explicitly enforced by the user or 
    % they happen automatically (for ex, model reference blocks) 
    if isfield(modelInformation,'ReplacementModel')
        if isfield(modelInformation,'ExtractedModel')
            % Covers the case subsystem analysis + user enforced or 
            % automatic block replacement
            modelName = modelInformation.ExtractedModel;
        else
        	% Covers the case for user enforced or 
            % automatic block replacement
            modelName = modelInformation.Name;
        end
        inputPortInfoMapped = mapBlockPath(modelName, sldvDataMapped.AnalysisInformation.InputPortInfo);
        outputPortInfoMapped = mapBlockPath(modelName, sldvDataMapped.AnalysisInformation.OutputPortInfo);        
        sldvDataMapped.AnalysisInformation.InputPortInfo = inputPortInfoMapped;
        sldvDataMapped.AnalysisInformation.OutputPortInfo = outputPortInfoMapped;
    end    
end

function portInfoMapped = mapBlockPath(modelName, portInfo)    
    numPorts  = length(portInfo);
    portInfoMapped = portInfo;
    for idx = 1:numPorts       
        portInfoMapped{idx} = replaceModelName(portInfo{idx},modelName);
    end
end

function portInfoMapped = replaceModelName(portInfo,modelName)
    portInfoMapped = portInfo;
    blockPath = portInfoMapped.BlockPath;
    index = strfind(blockPath,'/');
    assert(~isempty(index));
    portInfoMapped.BlockPath = [modelName blockPath(index(1):end)];
end