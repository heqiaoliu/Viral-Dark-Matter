function node = createTstoolNode(ts,~,varargin)
%
% tstool utility function
% Temporary file to be used until methods of Simulink data logs clasess are
% available
%
% This function could be called in place of ModelDataLogs/creatTstoolNode,
% etc, of those methods are not detected.

%   Copyright 2005-2010 The MathWorks, Inc.
%   % Revision % % Date %

%% Creates a node for the ModelDataLogs object (ts) to be inserted in the
%tstool's tree viewer. h is the parent node (@SimulinkTsParentNode). 
% Info from h is required to check against existing node with same name.

node = [];

%disp(sprintf('Temporary call to this createTstoolNode for class %s',class(ts)))

if nargin>2 && ~isempty(varargin{1})
    Label = [varargin{1},' (',ts.Name,')'];
else
    Label = ts.Name;
end

switch class(ts)
    case 'Simulink.ModelDataLogs'
        % Create a @modelDataLogsNode
        node = tsguis.modelDataLogsNode(Label,ts);
    case 'Simulink.SubsysDataLogs'
        % Create a @subsysDataLogsNode
        node = tsguis.subsysDataLogsNode(Label,ts);
    case 'Simulink.StateflowDataLogs'
        node = tsguis.stateflowDataLogsNode(Label,ts);
    case 'Simulink.ScopeDataLogs'
        node = tsguis.scopeDataLogsNode(Label,ts);
end
   
localAddChildNode(ts,node);

%--------------------------------------------------------------------------        
function localAddChildNode(tsParent,node)
        
% now add children nodes 
% (ModelDataLogs may contain SubsysDataLogs, Timseseries, TsArray and other
%  children nodes.)
Members = tsParent.whos;

for k = 1:length(Members)
    thisdataobj = eval(['tsParent.',Members(k).name]);
    childnode = createTstoolNode(thisdataobj,node);
    if ~isempty(childnode)
        node.addNode(childnode);
    end
end %end for Members
