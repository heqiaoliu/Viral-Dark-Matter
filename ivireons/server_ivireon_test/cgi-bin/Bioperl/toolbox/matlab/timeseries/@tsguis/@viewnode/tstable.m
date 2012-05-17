function tstable(h)

% Copyright 2004-2008 The MathWorks, Inc.

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

if ~isempty(h.TableListener)
    h.TableListener.Enable = 'off';
end
    
%% Syncs the timeseries table with the tsseriesview node. Used by the
%% listener to the tschanged event to update the list of time series in the
%% view
root = h.getRoot;
if ~isempty(h.Plot) && ~isempty(root)
    % Initilize vars
    tsList = h.Plot.getTimeSeries;
    tableData = cell([size(tsList,1),5]);
    
    % Update the time series table from the time series list and waveforms
    for k=1:length(tsList)
        tableData{k,1} = tsList{k}.Name;   
        tableData{k,2} = constructNodePath(root.find('Timeseries',tsList{k}));
        tableData{k,3} = sprintf('%d x %d',size(tsList{k}.Data,1),size(tsList{k}.Data,2));
        tableData{k,4} = sprintf('[ %s ]',num2str(h.Plot.Waves(k).Rowindex(:)'));
        tableData{k,5} = strcmp(h.Plot.waves(k).Visible,'on');
    end    
else
    tableData = cell(0,5);
end

%% Populate the table - if necessary creating it
headings = {xlate('Time series'),xlate('Path'),xlate('Size'),...
        xlate('Subplot Index'),xlate('Visible?')};
if ~isfield(h.Handles,'tsTable') || isempty(h.Handles.tsTable) ...
        || ~isjava(h.Handles.tsTable)
    h.Handles.tableModel = tsMatlabCallbackTableModel(tableData,headings,...
        'tsDispatchTableCallback',{'tstablecb' 4 h});
    h.Handles.tableModel.setNoEditCols([0 1 2]);
    drawnow
    h.Handles.tsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',h.Handles.tableModel);
    h.Handles.tsTable.setName('tstable:viewtstableview');
    javaMethod('setSelectionMode',h.Handles.tsTable,ListSelectionModel.SINGLE_SELECTION);
    javaMethod('setCellSelectionEnabled',h.Handles.tsTable,false);
    javaMethod('setRowSelectionAllowed',h.Handles.tsTable,true);
    c = javaObjectEDT('javax.swing.JCheckBox');
    col4Handle = h.Handles.tsTable.getColumnModel.getColumn(4);
    javaMethod('setCellEditor',col4Handle,DefaultCellEditor(c));
    javaMethod('setCellRenderer',col4Handle,tsCheckBoxRenderer);
    sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.tsTable);
    [junk, h.Handles.PNLTsTable] = ... 
        javacomponent(sPanel,[0 0 1 1 ],ancestor(h.Handles.PNLTs,'figure'));
    set(h.Handles.PNLTsTable,'Parent',h.Handles.PNLTs);
    
    %% 1st column is HTML
    h.getRoot.setHTMTableColumn(h.Handles.tsTable);
   
else
    % Quick return if nothing has changed
    if isequal(cell(h.Handles.tsTable.getModel.getData),tableData)
       h.TableListener.Enable = 'on';
       return
    end
    tableModel = h.Handles.tsTable.getModel;
    javaMethod('setDataVector',tableModel,tableData,headings,h.Handles.tsTable);
end
h.TableListener.Enable = 'on';


