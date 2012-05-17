function initialize(h,manager,varargin)

% Copyright 2004-2008 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import javax.swing.*;
import com.mathworks.mwswing.*;

%% Builds the arithmetic dialog

% Main figure
h.Figure = figure('Units','Characters','Position',[103.8 26.3 45.6 33.154],'Toolbar',...
    'None','Numbertitle','off','Menubar','None','Name','Transform Data Algebraically',...
    'Visible','off','closeRequestFcn',@(es,ed) set(h,'Visible','off'),...
    'HandleVisibility','off','IntegerHandle','off');

% Time series panel
h.Handles.TSPanel = uipanel('Parent',h.Figure,'Units','Characters','Position',...
    [1 16.5 62 13.308],'Title',xlate('Time series'));
h.Handles.tsTableModel = tsMatlabCallbackTableModel(cell(0,4),...
            {xlate('Identifier'),xlate('Name'),xlate('Path'),xlate('Size')},[],[]);
h.Handles.tsTableModel.setEditable(false);
drawnow
h.Handles.tsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
    h.Handles.tsTableModel);
javaMethod('setPreferredWidth',h.Handles.tsTable.getColumnModel.getColumn(2),...
    150);
h.Handles.tsTable.setName('arithdlg:tstable');
javaMethod('setAutoResizeMode',h.Handles.tsTable,JTable.AUTO_RESIZE_OFF);
javaMethod('setReorderingAllowed',h.Handles.tsTable.getTableHeader,false);
javaMethod('setSelectionMode',h.Handles.tsTable,ListSelectionModel.SINGLE_SELECTION);
sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.tsTable);
[junk, h.Handles.tsTablePanel] = javacomponent(sPanel,[0 0 1 1],h.Figure);
set(h.Handles.tsTablePanel,'Units','Normalized','Parent',h.Handles.TSPanel,'Position', ...
    [.02 .05 .94 .9]);

% 2nd column is HTML
v = tsguis.tsviewer;
v.TreeManager.Root.setHTMTableColumn(h.Handles.tsTable,2);

%%List selection listener must update time series table changed status
listSelectionListener = ...
    handle(h.Handles.tsTable.getSelectionModel,'callbackproperties');
listSelectionListener.ValueChangedCallback = {@localTsSelection h};

% Expression components
uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'Position',[3.2 9.7 68 1.1540],'String',...
    xlate('Expression: Use the identifier to refer to a time series e.g., a*25'),...
    'HorizontalAlignment','Left');
h.Handles.TXTexp = uicontrol('Style','Edit','Parent',h.Figure,'Units','Characters',...
    'Position',[3.2 7.646 58.4 1.6150],'HorizontalAlignment','Left',...
    'Backgroundcolor',[1 1 1],'TooltipString','Enter MATLAB expression');

% Output components
uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'Position',[3.2 5.885 40 1.154],'String',...
    xlate('New time series:'),'HorizontalAlignment','Left');
h.Handles.COMBnewTs = uicontrol('Style','Popupmenu','Parent',h.Figure,'Units','Characters',...
    'HorizontalAlignment','Left',...
    'Backgroundcolor',[1 1 1],'String',{xlate('Replace selected time series');...
    xlate('Create new time series')},'Value',1,'Callback',{@localreplaceNewcb h});
h.Handles.LBLpath = uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'String',xlate('Path'),'HorizontalAlignment','Left','Visible','on');
h.Handles.LBLnewname = uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'String',...
    'New name:','HorizontalAlignment','Left','Visible','off');
h.Handles.TXToutname = uicontrol('Style','Edit','Parent',h.Figure,'Units','Characters',...
    'HorizontalAlignment','Left',...
    'Backgroundcolor',[1 1 1],'Visible','off'   );
h.Handles.TXTpath = uicontrol('Style','Edit','Parent',h.Figure,'Units','Characters',...
    'HorizontalAlignment','Left',...
    'Backgroundcolor',[.9 .9 .9],'Visible','on');

% Buttons
h.Handles.BTNapply = uicontrol('Style','pushbutton','Parent',h.Figure,'Units','Characters',...
    'String','Apply',...
    'HorizontalAlignment','Center','Callback',{@localApply h});
h.Handles.BTNcancel = uicontrol('Style','pushbutton','Parent',h.Figure,'Units','Characters',...
    'String','Close',...
    'HorizontalAlignment','Center','Callback',@(es,ed) set(h,'Visible','off'));
h.Handles.BTNhelp = uicontrol('Style','pushbutton','Parent',h.Figure,'Units','Characters',...
    'String','Help',...
    'HorizontalAlignment','Center','Callback',...
    @(es,ed) tsDispatchHelp('d_transform_data','modal',h.Figure));

% Set the figure background to match the labels
set(h.Figure,'color',get(h.Handles.LBLpath,'backgroundcolor'))

% Install general listeners
h.generic_listeners;
manager.Listeners.addListeners(handle.listener(manager,manager.findprop('Visible'),...
    'PropertyPostSet',{@localHide h manager}));
set(h.Figure,'ResizeFcn',{@localResize h});
% The resize event must be triggered after the dialog is visible on the MAC
% (g479125).
if ~ismac
    localResize(h.Figure,[],h);
end
set(h.Figure,'Visible','on')

function localApply(eventSrc,eventData,h)

% OK button callback 
[ok,newnode] = h.eval;

% Close on success
if ok && ~isempty(newnode)
   v = tsguis.tsviewer;
   v.TreeManager.reset
   v.TreeManager.Tree.setSelectedNode(newnode.getTreeNodeInterface)  
   drawnow;drawnow % Force the node to show seelcted
   v.TreeManager.Tree.repaint
end

function localHide(es,ed,h,manager)

%% Listener to tree manager hide will hide the stats dlg
if strcmp(manager.Visible,'off')
    set(h,'Visible','off')
end

function localResize(es,ed,h)

pos = hgconvertunits(h.Figure,get(es,'Position'),get(es,'Units'),...
        'Characters',h.Figure);
if pos(3)<80 || pos(4)<25
    set(es,'Units','Characters','Position',[pos(1:2) 80 25]);
    centerfig(es);
    pos = get(es,'Position');
end

% Reposition the buttons
set(h.Handles.BTNapply,'Position',[pos(3)-47.4 0.846 13.8 1.769]);
set(h.Handles.BTNcancel,'Position',[pos(3)-32.4 0.846 13.8 1.769]);
set(h.Handles.BTNhelp,'Position',[pos(3)-17.4 0.846 13.8 1.769]);

% Resposition the other components
set(h.Handles.COMBnewTs,'Position',[3.2 3.523+.5 35 1.615]);
set(h.Handles.LBLpath,'Position',[40 3.123+.5 12 1.615]);
set(h.Handles.LBLnewname,'Position',[40 3.123+.5 12 1.615]);
set(h.Handles.TXToutname,'Position',[54 3.523+.5 pos(3)-58 1.615]);
set(h.Handles.TXTpath,'Position',[49 3.523+.5 pos(3)-53 1.615]);
set(h.Handles.TXTexp,'Position',[3.2 7.646 pos(3)-7.2 1.615]);
set(h.Handles.TSPanel,'Position',[3 12 pos(3)-7 pos(4)-13]);

function localreplaceNewcb(es,ed,h)

if get(h.Handles.COMBnewTs,'Value')==1
    set(h.Handles.LBLpath,'Visible','on');
    set(h.Handles.LBLnewname,'Visible','off');
    set(h.Handles.TXToutname,'Visible','off');
    set(h.Handles.TXTpath,'Visible','on');
else
    set(h.Handles.LBLpath,'Visible','off');
    set(h.Handles.LBLnewname,'Visible','on');
    set(h.Handles.TXToutname,'Visible','on');
    set(h.Handles.TXTpath,'Visible','off');
end

function localTsSelection(es,ed,h)

selRow = h.Handles.tsTable.getSelectedRows;
if selRow>=0
   tableData = cell(h.Handles.tsTable.getModel.getData);
   set(h.Handles.TXTpath,'String',tableData{selRow+1,3});
end