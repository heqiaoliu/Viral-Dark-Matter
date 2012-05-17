function exportSelectedObjects(this,pos,manager)
% Export selected timeseries objects to workspace or file depending upon the
% value of popupVal.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/07/18 18:44:22 $

%% Find the time series selected in the table
selectedRows = double(this.Handles.tsTable.getSelectedRows)+1;
nodes = {};
tableData = cell(this.Handles.tableModel.getData);
for k = 1:length(selectedRows)
    potential_nodes = this.find('Label',tableData{selectedRows(k),1},'-depth',inf);
    if ~isempty(potential_nodes)
        nodes{end+1} = potential_nodes(1); %#ok<AGROW>
    end
end

%% Warn if no selection
if isempty(nodes)
    errordlg('Select the row corresponding to the objects you want to export.',...
            'Time Series Tools','modal')
    return
end

switch pos
    case 2
        % Export to file
        localExportToFile(nodes,manager);
    case 3
        % Export to workspace
        this.exportToWorkspace(nodes);
end

%--------------------------------------------------------------------------
function localExportToFile(nodes,manager)

dlg = tsguis.allExportdlg;
dlg.initialize('file',manager.Figure,nodes);
