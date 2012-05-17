function [handle,auxInfo,blockH] = ssIdToHandle(ssId)

%   Copyright 2007-2010 The MathWorks, Inc.

handle = [];

% parse the SSId
[blockPath ssIdNumber auxInfo] = traceabilityManager('parseSSId', ssId);
if isempty(blockPath)
    return;
end

try
    % get handle to the chart
    blockH = get_param(blockPath,'handle');
    chartId = block2chart(blockH);
    chartHandle = idToHandle(sfroot,chartId);
    if isempty(chartHandle)
        return;
    end
    
    % special case when this is an eml chart and the ssIdNumber is
    % actually part of the auxInfo
    if isa(chartHandle, 'Stateflow.EMChart') && ~isempty(auxInfo) && auxInfo(1)=='-'
        handle = chartHandle;
        auxInfo = [ssIdNumber auxInfo];
        return;
    end
    
    
    % find the object with the ssId
    objectList = getObjectList(chartHandle.Id);
    objectId = sf('find', objectList, '.ssIdNumber', str2double(ssIdNumber));
    
    % get the handle to the object
    if objectId ~= 0
        handle = idToHandle(sfroot, objectId);
        
        % return the chart handle for EML Function Block and Truth Table Block
        % states
        if isempty(handle)
            handle = idToHandle(sfroot, getChartOf(objectId));
        end
        
    end
    
catch ME           %#ok<NASGU>
    return;
end



% get the object list to search based on the objectTypeChar
function objectList = getObjectList(chartId)

stateList = sf('get', chartId, 'chart.states');
transList = sf('get', chartId, 'chart.transitions');
juncList = sf('get', chartId, 'chart.junctions');
dataList = sf('DataIn', chartId);
eventList = sf('EventsIn', chartId);
objectList = [stateList, transList, juncList, dataList, eventList];

