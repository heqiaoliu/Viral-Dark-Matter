function tstable(h,varargin)

% Copyright 2004-2008 The MathWorks, Inc.

%return;
import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

%% Method which builds/populates the timeseries table on the viewcontainer panel

if isempty(h.Handles) || isempty(h.Handles.PNLTs) || ...
        ~ishghandle(h.Handles.PNLTs)
    return % No panel
end

%% Assemble the timeseries table data by traversing each member timeseries of the
%% selected viewnode
if nargin>=2 && ~isempty(varargin{1}) && ~isempty(varargin{1}.Plot) &&...
        ishandle(varargin{1}.Plot)
    memberTs = varargin{1}.Plot.getTimeSeries;
    tableData = cell([length(memberTs) 3]);
    for k=1:length(memberTs)
        tableData(k,:) = {memberTs{k}.Name,localGetPath(h,memberTs{k})...
            sprintf('%dx%d',memberTs{k}.TimeInfo.Length, ...
            max(memberTs{k}.getdatasamplesize))};
    end
else
    tableData = cell([1 3]); % Must be at least 1 row or col format will bve lost
end

%% Populate the table - if necessary creating it
headings = {xlate('Time Series'),xlate('Path'),xlate('Dimensions')}; 
if ~isfield(h.Handles,'tsTable') || isempty(h.Handles.tsTable) || ...
        ~isjava(h.Handles.tsTable)
    % Parent figure passed as the first argument until uitables can
    % be parented directly to uipanels   
    h.Handles.tableModel = tsMatlabCallbackTableModel(tableData,headings,[],[]);
    h.Handles.tableModel.setEditable(false);
    h.Handles.tsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',h.Handles.tableModel);
    h.Handles.tsTable.setName('tstable:viewtstable');
    
    javaMethod('setSelectionMode',h.Handles.tsTable,ListSelectionModel.SINGLE_SELECTION);
    javaMethod('setCellSelectionEnabled',h.Handles.tsTable,ListSelectionModel.SINGLE_SELECTION);
    javaMethod('setRowSelectionAllowed',h.Handles.tsTable,true);
    javaMethod('setAutoResizeMode',h.Handles.tsTable,MJTable.AUTO_RESIZE_ALL_COLUMNS);
    sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.tsTable);
    [junk, h.Handles.PNLtsTable] = ... 
        javacomponent(sPanel,[0 0 1 1 ],ancestor(h.Handles.PNLTs,'figure'));
    set(h.Handles.PNLtsTable,'Parent',h.Handles.PNLTs,'Units','Normalized',...
        'Position',[0.02 0.02 0.96 0.96])
    
    % 1st column is HTML
    h.getRoot.setHTMTableColumn(h.Handles.tsTable);
    
    % If the hosting viewcontainer is invisible, make sure the table
    % panel is invisible or it might appear in the wrong panel since
    % this method may be called by selection callbacks when then 
    % other panels are showing
    set(h.Handles.PNLtsTable,'Visible',get(h.Dialog,'Visible'));
else
    % Quick return if nothing has changed
    if isequal(cell(h.Handles.tsTable.getModel.getData),tableData)
       return
    end
    javaMethod('setDataVector',h.Handles.tsTable.getModel,...
        tableData,headings,h.Handles.tsTable);
end

function pathspec = localGetPath(h,ts)

root = h.getRoot;
tsnode = root.find('Timeseries',ts);
if isempty(tsnode)
    pathspec = '';
    return
end
pathspec = tsnode.Label;
node = tsnode.up;
while ~isempty(node)
    pathspec = [node.Label '/' pathspec]; %#ok<AGROW>
    node = node.up;
end
