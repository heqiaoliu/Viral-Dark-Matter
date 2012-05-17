function exportToWorkspace(this,nodes,varargin)
%Export the model contained in this node to workspace.
%nodes is a cell array of nodes whos data need to be exported to the
%workspace.

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:59:42 $

%% export this object to workspace
List = evalin('base','who;');
if nargin<2
    nodes = {this};
end
allNames = '';
msg = '';
for k = 1:length(nodes)
    node = nodes{k};
    if isa(node,'tsguis.simulinkTsNode')
        thisName0 = node.Timeseries.Name;
        ts = node.Timeseries.copy;
    elseif isa(node,'tsguis.simulinkTsArrayNode')
        thisName0 = node.SimModelhandle.Name;
        ts = node.SimModelhandle.copy;
    else
        %{
        errordlg(sprintf('Objects of type %s cannot be exported to Workspace. Therefore, ''%s'' was not exported.',...
            class(node.SimModelhandle),node.SimModelhandle.Name),'Time Series Tools','modal')
        continue;
        %}
        thisName0 = node.SimModelhandle.Name;
        ts = node.SimModelhandle;
    end
    thisName = genvarname(thisName0);

    if ~strcmp(thisName,thisName0)
        %warning('tstool:InvalidObjectName',...;
        msg =   sprintf('The selected object name is an invalid MATLAB variable name. The object name was replaced by ''%s''.',...
            thisName);
    else
        msg = '';
    end


    if ~isempty(strmatch(thisName,List,'exact'))
        ButtonName = questdlg(sprintf('A variable with name %s already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?',thisName),...
            xlate('Duplicate Variable Detected'),'Overwrite','Abort','Overwrite');
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
    allNames = [allNames,'''',thisName,''', '];
end

if ~isempty(nodes)
    if isempty(msg)
        msgbox(sprintf('%s exported to the base workspace.',allNames(1:end-2)),...
            'Time Series Tools','modal');
    else
        msgbox(msg,'Time Series Tools','modal');
    end
end