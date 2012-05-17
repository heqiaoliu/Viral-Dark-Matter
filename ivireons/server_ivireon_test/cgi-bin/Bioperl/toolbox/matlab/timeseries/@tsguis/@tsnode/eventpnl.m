function eventpnl(this,eventPanel)

% Copyright 2004-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.13.2.1 $ $Date: 2010/06/21 18:00:22 $

%% Builds events panel for @tsnode
import javax.swing.*;

%% Create the node panel and components
localBuildPanel(this,eventPanel);
set(eventPanel,'ResizeFcn',{@localEventsResize this})

%% Temporary listeners to update table visibility when the enclosing panel
%% visibility is modified
% h = handle(eventPanel);
% this.addListeners(handle.listener(h,h.findprop('Visible'),'PropertyPostSet',...
% {@localSetVisible h}));

%% Listener to the events stored in the timeseries
this.addListeners(handle.listener(this.Timeseries,...
    'datachange',...
    {@localEventsChange this.Timeseries this.Handles.eventTable this}));
localEventsChange([],[],this.Timeseries,this.Handles.eventTable)

%--------------------------------------------------------------------------
function localBuildPanel(h,PNLevents)

import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;

%% Events panel

h.Handles.BTNaddEvent = uicontrol('Style','pushbutton','Parent',PNLevents, ...
'Units','Pixels','String',xlate('Add event'),'Callback',@(es,ed) tsguis.neweventdlg(h,'open'),...
'Units','Characters');
h.Handles.BTNdelEvent = uicontrol('Style','pushbutton','Parent',PNLevents, ...
    'Units','Pixels','String',xlate('Delete event'),'Callback',{@localDelEvent h},...
    'Units','Characters');
h.Handles.eventTableModel = tsMatlabCallbackTableModel(cell([0,3]),...
           {xlate('Name'),xlate('Description'),xlate('Time')},'tsDispatchTableCallback',...
           {'eventTimeChange' 4 h});
h.Handles.eventTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
    h.Handles.eventTableModel); 
h.Handles.eventTable.setName('eventpnl:eventtable');
javaMethod('setSelectionMode',h.Handles.eventTable,...
    ListSelectionModel.SINGLE_SELECTION);
javaMethod('setCellSelectionEnabled',h.Handles.eventTable,false);
javaMethod('setRowSelectionAllowed',h.Handles.eventTable,false);
javaMethod('setRowHeight',h.Handles.eventTable,20);
javaMethod('setAutoResizeMode',h.Handles.eventTable,...
    MJTable.AUTO_RESIZE_ALL_COLUMNS);
sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',...
    h.Handles.eventTable);
[~, h.Handles.PNLeventTable] = ...
    javacomponent(sPanel,[0 0 1 1],ancestor(PNLevents,'figure')); 
set(h.Handles.PNLeventTable,'Parent',PNLevents,'Units','Pixels')

%--------------------------------------------------------------------------
% function localSetVisible(es,ed,h)
%
% children = h.find('-depth',inf,'-isa','uicontainer');
% if ~isempty(children)
%    set(children,'Visible',get(h,'Visible'));
% end

%--------------------------------------------------------------------------
function localEventsChange(eventSrc,eventData,ts,eventTable,varargin)

% Listener callback to @eventsnode "Events" property which keeps the event
% table in sync
tableData = cell(length(ts.Events),3);
for k=1:length(ts.Events)
    evTimeStr = ts.Events(k).getTimeStr(ts.TimeInfo.Units);
    if ischar(ts.Events(k).EventData)
        tableData(k,:) = {ts.Events(k).Name, ts.Events(k).EventData, evTimeStr{1}};
    else
        tableData(k,:) = {ts.Events(k).Name, '', evTimeStr{1}};
    end
end

% Passive table data change
javaMethod('setDataVector',eventTable.getModel,tableData,...
    {xlate('Name'),xlate('Description'),xlate('Time')},eventTable);

%--------------------------------------------------------------------------
function localDelEvent(es,ed,h)

selrow = h.Handles.eventTable.getSelectedRow+1;
if selrow>=1
    tableData = h.Handles.eventTable.getModel.getData;
    thiseventname = tableData(selrow,1);
    ind = find(strcmp(thiseventname,get(h.Timeseries.Events,{'Name'})));

    % Create transaction
    T = tsguis.transaction;
    T.ObjectsCell = {T.ObjectsCell{:}, h.Timeseries};
    recorder = tsguis.recorder;

    % Update the list of events
    h.Timeseries.Events(ind) = []; %#ok<FNDSB>

    %% Record action
    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Delete event'));
        T.addbuffer(['ind = strcmp(''' thiseventname ''',get(' h.Timeseries.Name '.Events,{''Name''}));']);
        T.addbuffer([h.Timeseries.Name '.Events(ind) = [];'],h.Timeseries);
    end

    % Store transaction
    T.commit;
    recorder.pushundo(T);
end
h.Timeseries.send('datachange')

%--------------------------------------------------------------------------
function localEventsResize(es,ed,h)

% Resize function for events panel

% use max to allow only positive positions
pos = get(es,'Position');
set(h.Handles.BTNaddEvent,'Position',[max(1,pos(3)-30) 0 14 1.46]);
set(h.Handles.BTNdelEvent,'Position',[max(1,pos(3)-15) 0 14 1.46]);
tablepos = hgconvertunits(ancestor(h.Handles.PNLeventTable,'figure'),...
    [1 2 max(1,pos(3)-2) max(1,pos(4)-3)],'Characters','Pixels',...
    get(h.Handles.PNLeventTable,'Parent'));
set(h.Handles.PNLeventTable,'Position',tablepos);