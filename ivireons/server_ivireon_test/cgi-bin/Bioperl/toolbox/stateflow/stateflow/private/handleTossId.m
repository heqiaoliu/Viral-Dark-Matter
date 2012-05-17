function [ssId varargout] = handleTossId(handle)

%   Copyright 2007-2009 The MathWorks, Inc.

ssId = [];

if isempty(handle)
    return;
end

% gather fields
try
    objectId = handle.Id;
    
    % block path
    blockId = getChartOf(objectId);
    if blockId == 0
        return;
    end
    
    % handle libraries. For a library chart whose instance is being
    % viewed, the activeInstance property points at the link-block.
    % if activeInstance is 0, then it is a real chart
    activeInstance = sf('get',blockId,'chart.activeInstance');
    if(activeInstance~=0.0)
        blockHandle = get_param(activeInstance,'object');
        blockPath = [blockHandle.path,'/',blockHandle.name];
    else
        rt = sfroot;
        blockHandle = rt.idToHandle(blockId);
        blockPath = blockHandle.path;
    end
    
    % for eml based charts we return the SSIdNumber of the state
    if is_eml_based_chart(blockId)
        stateIds = sf('get', blockId, '.states');
        if length(stateIds) ~= 1
            return;
        end
        objectId = stateIds(1);
    end
    
    % ssId number
    ssIdNumber = sf('get', objectId, '.ssIdNumber');

    % make ssId with empty auxInfo
    if nargout >= 2
        % Stateflow-part of SSID (not including Simulink block path)
        ssId = traceabilityManager('makeSSId', '', num2str(ssIdNumber), '');
        % return block path through second output argument
        varargout{1} = blockPath;
    else
        ssId = traceabilityManager('makeSSId', blockPath, num2str(ssIdNumber), '');
    end
        
    
catch ME
    disp(ME.message);
    return;
end
