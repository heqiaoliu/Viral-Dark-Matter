function busObj = get_port_bus_object(blockH, port, isOutput)

%   Copyright 2006-2008 The MathWorks, Inc.

if nargin < 3
    isOutput = 0; % Default to input ports
end

if isOutput
    scopeStr = 'OUTPUT';
else
    scopeStr = 'INPUT';
end

busObj = '';

chartId = block2chart(blockH);
chart = idToHandle(sfroot, chartId);
data = find(chart, '-depth', 1, '-isa', 'Stateflow.Data', 'Scope', scopeStr, 'Port', port); %#ok<GTARG>

if length(data) == 1
    switch data.Props.Type.Method
        case 'Expression'
            busObj = data.Props.Type.Expression;
        case 'Bus Object'
            busObj = data.Props.Type.BusObject;
    end
end

return;
