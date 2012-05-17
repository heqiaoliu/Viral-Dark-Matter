function viewstable(h,varargin)

% Copyright 2004-2008 The MathWorks, Inc.

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

%% Rebuld the views table. Additional argument is a view to be excluded
%% from the table because it is in the process of being removed.

%% Method which builds/populates the views table on the viewcontainer panel

if isempty(h.Handles) || isempty(h.Handles.PNLViews) || ...
        ~ishghandle(h.Handles.PNLViews)
    return % No panel
end
 
%% Assemble the views table data by traversing each child of the
%% viewcontainer
if nargin>=2
    views = setdiff(h.getChildren,varargin{1});
else
    views = h.getChildren;
end

tableData = cell([length(views) 3]);
for k=1:length(views)
    if ~isempty(views(k).Plot) && ishandle(views(k).Plot)
        xlim = views(k).Plot.axesgrid.getxlim{1};
        tableData(k,:) = {views(k).Label,views(k).Plot.AxesGrid.Title,...
            sprintf('%0.2g-%0.2g',xlim(1),xlim(2))};
    else
        tableData(k,:) = {views(k).Label,'[empty]',''}; 
    end
end

%% Populate the table - if necessary creating it
headings = {xlate('Node Label'),xlate('Title'),xlate('Domain Limits')};   
if ~isfield(h.Handles,'viewsTable') || isempty(h.Handles.viewsTable) ||...
        ~ishandle(h.Handles.viewsTable)   
    h.Handles.viewTableModel = tsMatlabCallbackTableModel(tableData,headings,[],[]);
    h.Handles.viewTableModel.setEditable(false);
    h.Handles.viewsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',h.Handles.viewTableModel); 
    h.Handles.viewsTable.setName('viewstable:viewtable');
    javaMethod('setSelectionMode',h.Handles.viewsTable,ListSelectionModel.SINGLE_SELECTION);
    javaMethod('setCellSelectionEnabled',h.Handles.viewsTable,false);
    javaMethod('setRowSelectionAllowed',h.Handles.viewsTable,true);
    javaMethod('setAutoResizeMode',h.Handles.viewsTable,MJTable.AUTO_RESIZE_ALL_COLUMNS);
    sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.viewsTable);
    [junk, h.Handles.PNLviewsTable] = ...
        javacomponent(sPanel,[0 0 1 1 ],ancestor(h.Handles.PNLViews,'figure'));
    set(h.Handles.PNLviewsTable,'Parent',h.Handles.PNLViews)
    
    % Select the first table row. Selection callback will update time series table 
    if size(tableData,1)>0
        javaMethod('setRowSelectionInterval',h.Handles.viewsTable,0,0);
    end
else
    if h.Handles.viewsTable.getRowCount>0 && size(tableData,1)>0
        javaMethod('setDataVector',h.Handles.viewsTable.getModel,...
            tableData,headings,h.Handles.viewsTable);
        javaMethod('setRowSelectionInterval',h.Handles.viewsTable,0,0);
    else
        javaMethod('clearSelection',h.Handles.viewsTable);
        javaMethod('setDataVector',h.Handles.viewsTable.getModel,...
            tableData,headings,h.Handles.viewsTable);
    end
end
