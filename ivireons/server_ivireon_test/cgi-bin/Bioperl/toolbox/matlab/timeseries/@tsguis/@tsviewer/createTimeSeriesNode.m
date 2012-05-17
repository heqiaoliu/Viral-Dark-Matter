function node = createTimeSeriesNode(h,ts)

% Copyright 2005 The MathWorks, Inc.

%% Mehtod which figures out wether to add the time series to the Simulink
%% parent node or the Timeseries parent, based on its class
node = [];
if isa(ts,'Simulink.Timeseries')
    node = ts.createTstoolNode(h.SimulinkTSnode);   
    if ~isempty(node)
        node = h.SimulinkTSnode.addNode(node);
    end
else
    node = ts.createTstoolNode(h.TSnode);    
    if ~isempty(node)
        node = h.TSnode.addNode(node);
    end
end


