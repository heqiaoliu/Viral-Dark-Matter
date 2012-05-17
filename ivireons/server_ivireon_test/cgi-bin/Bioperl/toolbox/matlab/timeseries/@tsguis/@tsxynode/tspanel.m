function tspanel(h)

% Copyright 2004-2008 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

localBuildPanel(h);
h.addlisteners(handle.listener(h.getRoot,'tsstructurechange',...
    {@localUpdateTables h}));


h.addlisteners(handle.listener(h,'tschanged',...
    {@localUpdateTsBoxes h}));
localUpdateTsBoxes([],[],h)
localUpdateTables([],[],h)

function localBuildPanel(h)

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

%% X axis panel
h.Handles.PNLXts = uipanel('Parent',h.Handles.PNLTs,'Units','Characters','Bordertype','none');
h.Handles.LBLtsxlabel = uicontrol('Style','text','String',xlate('Time series aligned with X axis'),...
    'HorizontalAlignment','left','Parent',h.Handles.PNLXts,'Units','characters');
h.Handles.BTNtsx= uicontrol('Style','pushbutton','String',xlate('Select'),...
    'Parent',h.Handles.PNLXts,'Units','characters');
h.Handles.TXTtsx = uicontrol('Style','text','HorizontalAlignment','left',...
    'Parent',h.Handles.PNLXts,'Units','characters','Backgroundcolor',[0.9 0.9 0.9]);


%% Xtable
h.Handles.tableModelX = tsMatlabCallbackTableModel(cell(0,2),...
    {xlate('Name'),xlate('Number of Columns')},[],[]);
h.Handles.tableModelX.setEditable(false);
drawnow
h.Handles.tsTableX = MJTable(h.Handles.tableModelX);
h.Handles.tsTableX.setName('tspanel:xyxtable');
h.Handles.tsTableX.getColumnModel.getColumn(0).setWidth(200);
h.Handles.tsTableX.getColumnModel.getColumn(1).setWidth(100);
h.Handles.tsTableX.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
h.Handles.tsTableX.setCellSelectionEnabled(false);
h.Handles.tsTableX.setRowSelectionAllowed(true);
h.Handles.tsTableX.setAutoResizeMode(MJTable.AUTO_RESIZE_ALL_COLUMNS);
sPanel = MJScrollPane(h.Handles.tsTableX);
[junk, h.Handles.PNLtsTableX] = ... 
    javacomponent(sPanel,[0 0 1 1 ],ancestor(h.Handles.PNLXts,'figure'));
    
set(h.Handles.PNLtsTableX,'Parent',h.Handles.PNLXts,'Units','Characters')
set(h.Handles.BTNtsx,'Callback',{@localSelectTs h h.Handles.tsTableX h.Handles.TXTtsx 'x'})   
%% Y axis panel
h.Handles.PNLYts = uipanel('Parent',h.Handles.PNLTs,'Units','Characters','Bordertype','none');
h.Handles.LBLtsylabel = uicontrol('Style','text','String',xlate('Time series aligned with Y axis'),...
    'HorizontalAlignment','left','Parent',h.Handles.PNLYts,'Units','characters');
h.Handles.BTNtsy = uicontrol('Style','pushbutton','String',xlate('Select'),...
    'Parent',h.Handles.PNLYts,'Units','characters');
h.Handles.TXTtsy = uicontrol('Style','text','HorizontalAlignment','left',...
    'Parent',h.Handles.PNLYts,'Units','characters','Backgroundcolor',[0.9 0.9 0.9]);

%% Y Table
h.Handles.tableModelY = tsMatlabCallbackTableModel(cell(0,2),...
    {xlate('Name'),xlate('Number of Columns')},[],[]);
h.Handles.tableModelX.setEditable(false);
drawnow
h.Handles.tsTableY = javaObjectEDT('com.mathworks.mwswing.MJTable',...
    h.Handles.tableModelY);
h.Handles.tsTableY.setName('tspanel:xyytable');
javaMethod('setWidth',h.Handles.tsTableY.getColumnModel.getColumn(0),200);
javaMethod('setWidth',h.Handles.tsTableY.getColumnModel.getColumn(1),100);
javaMethod('setSelectionMode',h.Handles.tsTableY,...
    ListSelectionModel.SINGLE_SELECTION);
javaMethod('setCellSelectionEnabled',h.Handles.tsTableY,false);
javaMethod('setRowSelectionAllowed',h.Handles.tsTableY,true);
javaMethod('setAutoResizeMode',h.Handles.tsTableY,...
    MJTable.AUTO_RESIZE_ALL_COLUMNS);
sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.tsTableY);
[junk, h.Handles.PNLtsTableY] = ... 
    javacomponent(sPanel,[0 0 1 1 ],ancestor(h.Handles.PNLXts,'figure'));

set(h.Handles.PNLtsTableY,'Parent',h.Handles.PNLYts,'Units','Characters')
set(h.Handles.BTNtsy,'Callback',{@localSelectTs h h.Handles.tsTableY h.Handles.TXTtsy 'y'}) 
set(h.Handles.PNLXts,'ResizeFcn',{@localXYPnlResize h.Handles.LBLtsxlabel ...
    h.Handles.BTNtsx h.Handles.TXTtsx h.Handles.PNLtsTableX})
set(h.Handles.PNLYts,'ResizeFcn',{@localXYPnlResize h.Handles.LBLtsylabel ...
    h.Handles.BTNtsy h.Handles.TXTtsy h.Handles.PNLtsTableY})


%% Set resize behavior
set(h.Handles.PNLTs,'ResizeFcn',{@localTsPanelResize h.Handles.PNLXts h.Handles.PNLYts})


function localXYPnlResize(thisPnl,ed,LBLts,BTNts,TXTts,PNLtsTable)

% XY Panel resize callback

% Make the table and edit box take up all the horizontal space
pos = get(thisPnl,'Position');
set(LBLts,'Position',[2 max(1,pos(4)-3.25) 35 1.5]);
set(TXTts,'Position',[35 max(1,pos(4)-3) max(1,pos(3)-38-2) 1.2]);
set(PNLtsTable,'Position',[2 2 max(1,pos(3)-23) max(1,pos(4)-6)]);
set(BTNts,'Position',[max(1,pos(3)-18) 2 15 1.5]);


function localTsPanelResize(PNLts,ed,PNLXts,PNLYts)

% Resize fcn for the time series pane;

% Get sizes and margins
bmargin = 1;
pos = get(PNLts,'Position');
pnlheight = (max(1,pos(4)-3*bmargin))/2;

% Set positions
set(PNLXts,'Position',[bmargin 2*bmargin+pnlheight max(1,pos(3)-2*bmargin) pnlheight]);
set(PNLYts,'Position',[bmargin bmargin max(1,pos(3)-2*bmargin) pnlheight]);

function localUpdateTables(es,ed,h)

% Callback for ts objects update
rootNode = h.getRoot;
if isempty(rootNode) || ~ishandle(rootNode)
    return
end
[pathnames,tsnames] = dir(rootNode);
tableData = cell(length(tsnames),2);
tableData(:,1) = pathnames(:);
for k=1:length(pathnames)
    tableData{k,2} = sprintf('%d',...
        size(h.getRoot.search(pathnames{k}).Timeseries.Data,2));
end    
h.Handles.tsTableY.getModel.setDataVector(tableData,...
    {xlate('Name'),xlate('Number of Columns')},h.Handles.tsTableY);
h.Handles.tsTableX.getModel.setDataVector(tableData,...
    {xlate('Name'),xlate('Number of Columns')},h.Handles.tsTableX);

function localSelectTs(es,ed,h,tsTable,TXTts,pos)

% Write the seelcted row to the label
selectedRow = tsTable.getSelectedRow+1;
tableData = cell(tsTable.getModel.getData);
if selectedRow>0 % Use {} so that 'default' will show
    tspath = tableData{selectedRow,1};
    set(TXTts,'String',{tspath})
else
    return
end

%% Find the corresponding timeseries
ts = h.getRoot.getts({tspath});
ts = ts{1};

%% Add the new timeseries to the plot
if ~isempty(ts) % Add specified time series
    h.addTs(ts,pos); 
end 

function localUpdateTsBoxes(es,ed,h)

% Callback for the listeners to the Timeseries1 and Timeseries2 properties
% which update the edit boxes
if numel(h.Timeseries2)>0
    set(h.Handles.TXTtsy,'String',h.getRoot.trimPath(h.Timeseries2))
else
    set(h.Handles.TXTtsy,'String','');
end
if numel(h.Timeseries1)>0
    set(h.Handles.TXTtsx,'String',h.getRoot.trimPath(h.Timeseries1))
else
    set(h.Handles.TXTtsx,'String','');
end