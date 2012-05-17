function exportToWorkspace(this,nodes,varargin)
%Export the model contained in this node to workspace.
%nodes is a cell array of nodes whos data need to be exported to the
%workspace.

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/08/14 01:38:18 $

%% export this object to workspace
List = evalin('base','who;');

for k = 1:length(nodes)
    node = nodes{k};
    if isa(node,'tsguis.tsnode')
        thisName0 = node.Timeseries.Name;
        ts = timeseries(node.Timeseries.copy);
    else
        thisName0 = node.Tscollection.Name;
        tsh = node.Tscollection.copy;
        tsh.getTimeContainer.ReadOnly = 'on';
        ts = tscollection;
        ts.objH = tsh;
    end
    thisName = genvarname(thisName0);

    if ~strcmp(thisName,thisName0)
        warning('tstool:InvalidObjectName',...;
            '%s %s','The time series object name is invalid.',...
            'Attempting to replace it by a variable named ',['''',thisName,''''],'.');
    end

    if ~isempty(strmatch(thisName,List,'exact'))
        ButtonName = questdlg(sprintf('A variable with name ''%s'' already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?',thisName),...
            'Duplicated Variable Detected','Overwrite','Abort','Overwrite');
        ButtonName = xlate(ButtonName);
        switch ButtonName
            case xlate('Overwrite')
                assignin('base',thisName,ts);
            case xlate('Abort')
                return
        end
    else
        %ts = this.SimModelhandle.copy;
        assignin('base',thisName,ts);
    end
end

if ~isempty(nodes)
    msgbox('Objects have been exported to the base workspace.','Time Series Tools','modal');
end