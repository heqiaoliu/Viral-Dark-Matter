function exportSelectedObjects(this,popupVal,manager)
%Export selected timeseries objects to workspace or file depending upon the
%value of popupVal.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2008/07/18 18:44:15 $

thisTable = this.Handles.SelectedTable;

if isempty(thisTable)
    errordlg('Select the row corresponding to the objects you want to export.',...
        'Time Series Tools','modal')
    return
end

%% Find the time series selected in the table
selectedRows = thisTable.getSelectedRows;
nodes = {};
for k = 1:length(selectedRows)
    selRow = selectedRows(k);
    if selRow>=0
        thisNode = this.findNodeForATableRow(thisTable,selRow);
        if ~isempty(thisNode)
            nodes{end+1} = thisNode; %#ok<AGROW>
        end
    else
        errordlg('Select the row corresponding to the objects you want to export.',...
            'Time Series Tools','modal')
    end
end %for loop end

if isempty(nodes)
    return
end

switch popupVal
    case 2
        %export to file
        localExportToFile(nodes,manager);
    case 3
        %export to workspace
        this.exportToWorkspace(nodes);
end

%--------------------------------------------------------------------------
function localExportToFile(nodes,manager)
%Workaround: until export of multiple objects to a single file is
% made available, this function would need to be used.

% for k = 1:length(nodes)
%     node = nodes{k};
%     %% Open export for selected time series node
%     dlg = tsguis.allExportdlg;
%     if isa(node,'tsguis.simulinkTsNode')
%         dlg.initialize('file',manager.Figure,node.Timeseries);
%     else
%         dlg.initialize('file',manager.Figure,node.SimModelhandle);
%     end
% end %for loop end
dlg = tsguis.allExportdlg;
dlg.initialize('file',manager.Figure,nodes);
