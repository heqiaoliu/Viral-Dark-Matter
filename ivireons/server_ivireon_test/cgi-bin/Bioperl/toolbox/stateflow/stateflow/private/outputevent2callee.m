function calleeH = outputevent2callee(eventId)

% Copyright 2005-2008 The MathWorks, Inc.

calleeH = -1;
try
    calleeH =  try_outputevent2callee(eventId);
catch ME
    calleeH = -1;
end
        

function calleeH =  try_outputevent2callee(eventId)

calleeH = -1;
if(isempty(sf('find',eventId,'event.scope','OUTPUT_EVENT')))
    return;
end

chartId = sf('get',eventId,'event.linkNode.parent');
activeInstance = sf('get',chartId,'chart.activeInstance');
if(activeInstance==0.0)
    activeInstance = chart2block(chartId);
end

outputData = sf('find',sf('DataOf',chartId),'data.scope','OUTPUT_DATA');
outputEvents = sf('find',sf('EventsOf',chartId),'event.scope','OUTPUT_EVENT');
eventPortIndex = find(outputEvents==eventId)+length(outputData);

portHandles = get_param(activeInstance,'PortHandles');

eventPortHandle = portHandles.Outport(eventPortIndex);
eventLine = get_param(eventPortHandle,'Line');
if(ishandle(eventLine))
    calleeH = get_param(eventLine,'DstBlockHandle');
    if(length(calleeH)>1)
        calleeH = calleeH(1);
    end
    calleeH = skip_muxes(calleeH);
end

    
function calleeH = skip_muxes(calleeH)
    while(strcmp(get_param(calleeH,'BlockType'),'Mux'))
        portHandles = get_param(calleeH,'PortHandles');
        outputLine = get_param(portHandles.Outport(1),'Line');
        if(ishandle(outputLine))
            calleeH = get_param(outputLine,'DstBlockHandle');
        else
            return;
        end 
    end







