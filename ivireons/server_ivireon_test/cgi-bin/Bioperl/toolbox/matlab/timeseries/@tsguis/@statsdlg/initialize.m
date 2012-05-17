function initialize(h,manager)

%   Copyright 2004-2009 The MathWorks, Inc.
%   % Revision % % Date %
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;

%% Builds the Descriptive Stats dialog

% % % % %% Main figure
h.Figure = figure('Units','Characters','Position',[103 31 77.2 30.6],'Toolbar',...
    'None','Numbertitle','off','Menubar','None','Name','Descriptive Statistics',...
    'Visible','off','closeRequestFcn',@(es,ed) set(h,'Visible','off'),...
    'HandleVisibility','callback','IntegerHandle','off','Resize','off', 'Tag', 'DescriptiveStats');
centerfig(h.Figure);

% Labels
uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'Position',[2.8 27.61 17.8 1.154],'String','Select time series',...
    'HorizontalAlignment','Left');
uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'Position',[2.8 14.154 55.2 1.154],'String',...
    'Descriptive statistics summary for selected time series',...
    'HorizontalAlignment','Left');

%% Build time series table
h.Handles.tsTableModel = tsMatlabCallbackTableModel(cell(0,3),...
             {xlate('Time Series'),xlate('Path'),xlate('Number of Columns')},...
             [],[]);
h.Handles.tsTableModel.setEditable(false);
drawnow
h.Handles.tsTable = MJTable(h.Handles.tsTableModel);
h.Handles.tsTable.setName('statsdlg:tstable');
h.Handles.tsTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
h.Handles.tsTable.getColumnModel.getColumn(1).setPreferredWidth(150);
h.Handles.tsTable.getColumnModel.getColumn(2).setPreferredWidth(150);
h.Handles.tsTable.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
h.Handles.tsTable.setCellSelectionEnabled(false);
h.Handles.tsTable.setRowSelectionAllowed(true);
sPanel = MJScrollPane(h.Handles.tsTable);
[~, tsTablePanel] = javacomponent(sPanel,[0 0 1 1],h.Figure);
set(tsTablePanel,'Parent',h.Figure,'Units','Characters','Position',...
    [4 18 69.4 8.385])

%% 1st column is HTML
h.SrcNode.setHTMTableColumn(h.Handles.tsTable);

%% List selection listener must update time series table changed status
listSelectionListener = ...
    handle(h.Handles.tsTable.getSelectionModel,'callbackproperties');
listSelectionListener.ValueChangedCallback = {@localTsSelection h};

%% Stats table
h.Handles.statsTableModel = tsMatlabCallbackTableModel(cell(0,6),...
             {xlate('Column #'),xlate('Mean'),xlate('Median'),xlate('STD'),xlate('Min'),xlate('Max')},...
             [],[]);
h.Handles.statsTableModel.setEditable(false);
drawnow
h.Handles.statsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
    h.Handles.statsTableModel);
h.Handles.statsTable.setName('statsdlg:statstable');
javaMethod('setAutoResizeMode',h.Handles.statsTable,...
    JTable.AUTO_RESIZE_ALL_COLUMNS);
sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',...
    h.Handles.statsTable);
[~, statsTablePanel] = javacomponent(sPanel,[0 0 1 1],h.Figure);
set(statsTablePanel,'Parent',h.Figure,'Units','Characters','Position',...
    [4 5 69.4 8.385])

% Dialog buttons
BTNcancel = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'Position',[59.8-15 0.769 13.8 1.769],'String','Close','Callback', ...
    @(es,ed) set(h,'Visible','off'), 'Tag', 'BTNClose');
uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'Position',[59.8 0.769 13.8 1.769],'String','Help','Callback', ...
    'tsDispatchHelp(''d_descriptive_statistics'',''modal'')');
set(h.Figure,'Color',get(BTNcancel,'BackgroundColor'));

% Install general listeners
h.generic_listeners
manager.Listeners.addListeners(handle.listener(manager,manager.findprop('Visible'),...
    'PropertyPostSet',{@localHide h manager}));

function localTsSelection(~,eventData,h)

% Callback for row selection in time series table
selectedRow = eventData.getSource.getMaxSelectionIndex+1;
if selectedRow>0
    tableData = cell(h.Handles.tsTable.getModel.getData);
    tspath = tableData{selectedRow,2};
    h.Timeseries = h.Srcnode.search(tspath).Timeseries;
    h.updatestats
end

h.tslisteners = handle.listener(h.Timeseries,'datachange', ...
    @(es,ed) updatestats(h));

function localHide(~,~,h,manager)

% Listener to tree manager hide will hide the stats dlg
if strcmp(manager.Visible,'off')
    set(h,'Visible','off')
end
