function node = createTstoolNode(ts,h,varargin)
%

% Creates a node for the ModelDataLogs object (ts) to be inserted in the
% tstool's tree viewer. h is the parent node (@SimulinkTsParentNode). 
% Info from h is required to check against existing node with same name.

nodeName = h.getTstoolNodeName(ts,'tsguis.modelDataLogsNode',varargin{:});
if isempty(nodeName)
    node = [];
    return;
end

% Create a @ModelDataLogsNode
node = tsguis.modelDataLogsNode(nodeName,ts);

% Add children nodes (ModelDataLogs may contain SubsysDataLogs, Timseseries, 
% TsArray and other children nodes.)
tsguis.addTstoolChildrenNodes(ts,node)
