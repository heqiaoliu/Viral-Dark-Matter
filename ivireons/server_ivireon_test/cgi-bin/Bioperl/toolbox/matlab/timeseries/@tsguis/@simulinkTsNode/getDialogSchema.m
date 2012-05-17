function Panel = getDialogSchema(this,manager)
%render the Simulink.Timeseries panel

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.15.2.1 $ $Date: 2010/06/21 18:00:19 $


import javax.swing.*;

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************

%% Create the node panel and components
% note: '.12g' is used as the sprintf format to display values in the
% 'redifine unform time vector' panel.
Panel = localBuildPanel(manager.Figure,this,manager);
% Delete the cleaner explicitly to prevent extra reference counts.
delete(warnCleaner);

%% Add a listener to node renaming
Lrename = handle.listener(this.getRoot,'tsstructurechange', @localTsNameChange);
Lrename.CallbackTarget = this.up;
this.addListeners(Lrename);

%% Listener to destroy new time vector dialog
L = handle.listener(this,'ObjectParentChanged',@(es,ed) delete(get(this,'TimeResetPanel')));
this.addListeners(L);

% Temporary listeners to update table visibility when the enclosing panel
% visibility is modified
h = handle(Panel);
this.addListeners(handle.listener(h,h.findprop('Visible'),'PropertyPostSet',...
    {@localSetVisible,h,this}));

if strcmp(manager.Visible,'on')
    figure(double(manager.Figure))
end


%--------------------------------------------------------------------------
function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
f = uipanel('Parent',thisfig,'Units','Characters','Visible','off',...
    'tag','BigOuterPanel2');

HV = get(thisfig,'HandleVisibility');
set(thisfig,'HandleVisibility','on');

h.Handles.uTabGroup = uitabgroup('Parent',f,'Units','Characters',...
     'tag','TabGroup','selectionChangeCallback',{@localTabSelectionChange h manager f});
set(h.Handles.uTabGroup,'parent',f);
jtp = getappdata(handle(h.Handles.uTabGroup),'JTabbedPane');
jtp.setName('SimulinkTsTabGroup');

h.Handles.utabPlot = uitab('Parent',h.Handles.uTabGroup,'Title',xlate('Time Series Plot'),...
    'tag','plottab','Units','Characters');
h.Handles.utabData = uitab('Parent',h.Handles.uTabGroup,'Title',xlate('Time Series Data'),...
    'tag','datatab','Units','Characters');
% There is a bug in uitabgroup where the tabs will show visible even in 
% an invisible uitabgroup. Therefore set the uitabgroup invisible as soon as 
% possible after they are added to minimize flicker. We originally tried
% setting the initial size if the uitabgroup to be very small and then
% expanding it after it was visible but this caused repaint problems in
% JRE 6.0 (see g.531959)
set(h.Handles.uTabGroup,'visible','off');

% Assemble the plot panel
h.syncPlotInfo; %sync the read-only textual and plot display with timeseries data

set(thisfig,'HandleVisibility',HV);

% Resize functions
set(f,'ResizeFcn',{@localFigResize h.Handles.uTabGroup});

set(h.Handles.utabPlot,'ResizeFcn',{@localFigResize,h.Handles.PlotTextInfoPanel,...
    h.Handles.PlotViewPanel});

%--------------------------------------------------------------------------
function localFigResize(es,ed,varargin)
%% Resize callback for tsnode panel
 

%% No-op if the panel is invisible or if there is no eventData passed with
%% the firing resize event
if strcmp(get(es,'Visible'),'off') && isempty(ed)
    return
end

%% Components and panels are repositioned relative to the main panel
mainpnlpos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Characters',get(es,'Parent'));

switch get(es,'tag')
    case 'BigOuterPanel2'
        uTabGroup = varargin{1};
        
        if mainpnlpos(4)<=3
            return
        end

        %% Set the time series selector size
        set(uTabGroup,'pos',[0 0 mainpnlpos(3)-0.75 mainpnlpos(4)-.5]);
    case 'datatab'
        %disp('----')
        PNLdata = varargin{1};
        BTNGRPdisp = varargin{2};
        set(BTNGRPdisp,'Position',[1.8 1.2304 max(1,mainpnlpos(3)-4.8) 6]);

        %% Set the table panel size to take up remaining space 18.5317
        set(PNLdata,'Position',[1.8 8 max(1,mainpnlpos(3)-4.8) max(1,mainpnlpos(4)-9)]);
    case 'plottab'
        %disp('----');%dbstack('-completenames'),disp('----')
        TextPNL = varargin{1};
        ViewPNL = varargin{2};
        
        ht = 7;
        ypos = mainpnlpos(4)-ht;
        xlim = mainpnlpos(3)-2;
        if ypos<=0
            return
        end
        set(TextPNL,'pos',[1, ypos, xlim, ht]);  
        set(ViewPNL,'pos',[1, 1, xlim, ypos-1.5]);
end

%--------------------------------------------------------------------------
function localSetVisible(es,ed,panel,this,varargin) %#ok<*INUSL>

set(this.Handles.uTabGroup,'Visible',get(panel,'Visible'));

%--------------------------------------------------------------------------
function localSetTabVisible(es,ed,h,f)
% Toggle the visibility of tables on the data panel, according to whether
% the parent uitab ("datatab") is selected (visible) or not.

%this: simulinkTsNode
if strcmp(get(f,'Visible'),'on')
    Vtab = get(h.Handles.utabData,'vis');
    set(h.Handles.TablePanel,'Visible',Vtab);
%     if get(h.Handles.CHKevents,'Value')>0.5
%         set(h.Handles.PNLeventTable,'Visible',Vtab);
%     else
%         set(h.Handles.PNLeventTable,'Visible','off');
%     end
end


%--------------------------------------------------------------------------
function localTsNameChange(eventSrc,eventData)
% If the node name changes, the PropertyPostSet listener to this event 
% calls this callback function. The listener
% is installed above, in the simulinkTsNode/getDialogSchema initialization.

%% Rename only
if ~strcmp(eventData.Action,'rename') || ...
        ~any(ismember(eventSrc.getChildren,eventData.Node))
    return
end
% update the "Name" field in the info pane
if isfield(eventData.Node.Handles,'PlotTextInfo') && ~isempty(eventData.Node.Handles.PlotTextInfo) &&...
        ishghandle(eventData.Node.Handles.PlotTextInfo)
    str = get(eventData.Node.Handles.PlotTextInfo,'string');
    str{1} = sprintf('Name: %s',eventData.Node.Timeseries.Name);
    set(eventData.Node.Handles.PlotTextInfo,'string',str);
end

% Update tsnode group box label
editPanelStr = sprintf('Edit data for %s',eventData.Node.Timeseries.Name);
if isfield(eventData.Node.Handles,'PNLdata') % Data panel may not have been selected yet
   set(eventData.Node.Handles.PNLdata,'Title',editPanelStr);
end
%--------------------------------------------------------------------------
function localTablePnlResize(eventSrc, eventData, BTNattributes, ...
    BTNaddrow,BTNdelrow,CHKevents,PNLtable)

%% Table panel resize function keeps the buttons on the bottom right hand
%% corner - the table takes up the remaining space
pos = get(eventSrc, 'Position');
set(BTNattributes,'Position',[max(1,pos(3)-46) 1 15 1.4611]);
set(BTNaddrow,'Position',[max(1,pos(3)-30) 1 14 1.46 ]);
set(BTNdelrow,'Position',[max(1,pos(3)-15) 1 15 1.46 ]);
set(CHKevents,'Position',[1 1 28 1.46 ]);
tablePos =  hgconvertunits(ancestor(PNLtable,'figure'),...
             [1 3.46 max(1,pos(3)-2) max(1,pos(4)-3.46-1)],...
            'Characters','Pixels',get(PNLtable,'Parent'));
set(PNLtable,'Position',tablePos);

%--------------------------------------------------------------------------
function localDataResize(es,ed,h)

%% Data panel resize fcn
pos = get(es,'Position');

if get(h.Handles.CHKevents,'Value')>0.5
    set(h.Handles.PNLtstable,'Position',[1 2+pos(4)*.4 max(1,pos(3)-2) max(1,pos(4)*.6-3)]);
    set(h.Handles.PNLevents,'Position',[1 4.5 max(1,pos(3)-2) pos(4)*.4-2]);
else
    set(h.Handles.PNLtstable,'Position',[1 2.5 max(1,pos(3)-2) max(1,pos(4)-4)]);
end
set(h.Handles.BTNNewTimeVec,'Position',[max(1,pos(3)-31) .8 29 1.5]);


%--------------------------------------------------------------------------
function localShowEventTable(es,ed,h)

%% Events checkbox callback which shown the event pane
if get(h.Handles.CHKevents,'Value')
    set(h.Handles.PNLevents,'Visible','on');
else
    set(h.Handles.PNLevents,'Visible','off');
end
localDataResize(h.Handles.PNLdata,[],h);

%--------------------------------------------------------------------------
function localDelrow(es,ed,h)

hT = get(h,'Tstable');
selrow = hT.Table.getSelectedRows;

if ~isempty(selrow)
    % instantiate a transaction for row-deletion action
    recorder = tsguis.recorder;
    T = tsguis.transaction;
    T.ObjectsCell = [T.ObjectsCell(:); {h.Timeseries}];

    delrow(hT)

    if strcmp(recorder.Recording,'on')
        T.addbuffer(sprintf('%% Delete rows from timeseries ''%s''',h.Timeseries.Name));
        T.addbuffer(sprintf('%s = delsample(%s, ''index'',[%s]);',...
            h.Timeseries.Name, h.Timeseries.Name, num2str(selrow(:)'+1)),h.Timeseries);
    end

    %commit the transaction (r.s.)
    T.commit;
    recorder.pushundo(T);
end

function localTabSelectionChange(es,ed,h,manager,f)
ch = get(es,'Children');
firstChild = handle([]);
secondChild = handle([]);
try
   firstChild = ch(1);
   secondChild = ch(2);
catch ex
    if (~strcmpi(ex.identifier,'MATLAB:badsubscript'))
        rethrow(ex);
    end
end
   
if ~isfield(h.Handles,'PNLdata') && strcmp(ed.EventName,'SelectionChange') && ...
        isequal(ed.OldValue,handle(firstChild)) && isequal(ed.NewValue,handle(secondChild))
 
    % Data split pane
    editPanelStr = sprintf('Edit data for %s',h.Timeseries.Name);
    h.Handles.PNLdata = uipanel('Parent',h.Handles.utabData,'Units','Characters',...
        'Title',editPanelStr,'Visible','off');

    % Top tsdata panel
    h.Handles.PNLtstable = uipanel('Parent',h.Handles.PNLdata,'Units','Characters',...
        'BorderType','None');

    BTNattributes = uicontrol('Style', 'pushbutton','Parent',h.Handles.PNLtstable, ...
        'Units','Characters','String',xlate('Attributes...'),'Callback',...
        @(es,ed) tsguis.attributesdlg(h,'open'));
    h.Handles.CHKevents = uicontrol('Style','checkbox','Parent',h.Handles.PNLtstable, ...
        'Units','Characters','String',xlate('Show event table'),...
        'Value',true,'Callback',{@localShowEventTable h});
    h.Handles.BTNaddrow = uicontrol('Style','pushbutton','Parent',h.Handles.PNLtstable, ...
        'Units','Characters','String',...
        xlate('Add row'),'Callback',@(es,ed) addrow(get(h,'Tstable')));
    h.Handles.BTNdelrow = uicontrol('Style','pushbutton','Parent',h.Handles.PNLtstable, ...
        'Units','Characters','Interruptible','off',...
        'String',xlate('Delete row(s)'),'Callback',{@localDelrow,h});

    % Events panel
    h.Handles.PNLevents = uipanel('Parent',h.Handles.PNLdata,'Units','Characters',...
        'BorderType','None');
    h.eventpnl(h.Handles.PNLevents);


    % Build the tstableadaptor 
    h.Tstable = tsdata.tstableadaptor;
    h.Tstable.timeseries = h.Timeseries;
    h.Tstable.build;
    PNLtable = h.Tstable.addtopanel(h.Handles.PNLtstable);
    h.Handles.TablePanel = PNLtable;

    %% Time vector panel
    h.Handles.LBLCurrentTimeVec = uicontrol('Style','Text','Parent',h.Handles.PNLdata, ...
      'Units','Characters','String','','Position',[2.5 0.5 60 1.5],'HorizontalAlignment',...
      'Left');
    localUpdateTimeStr([],[],h);
    h.Handles.BTNNewTimeVec = uicontrol('Style','PushButton','Parent',h.Handles.PNLdata, ...
       'Units','Characters','String',xlate('Uniform Time Vector...'),...
       'Callback', {@localShowTimeReset h});

    % Size table
    tablePos =  hgconvertunits(ancestor(PNLtable,'figure'),...
                 [5.4 5.6137 117.6 31.1445],...
                'Characters','Pixels',get(PNLtable,'Parent'));
    set(PNLtable,'Visible','off','Parent',h.Handles.PNLtstable,'Position',tablePos)

    % View panel
    h.NewPlotPanel = tsguis.newplotpanel;
    h.NewPlotPanel.initialize(h.Handles.utabData,manager,h);

    % Temporary listeners to update panel visibility when the uitab visibility
    % is modified
    uh = handle(h.Handles.utabData);
    h.addListeners(handle.listener(uh,uh.findprop('Visible'),'PropertyPostSet',...
        {@localSetTabVisible,h,f}));
    
    % hide the events panel by default
    set(h.Handles.utabData,'ResizeFcn',{@localFigResize,h.Handles.PNLdata,...
         h.NewPlotPanel.Panel});
    set(h.Handles.PNLtstable, 'resizeFcn', ...
        {@localTablePnlResize BTNattributes h.Handles.BTNaddrow ...
        h.Handles.BTNdelrow h.Handles.CHKevents h.Handles.TablePanel});
    set(h.Handles.PNLdata,'ResizeFcn',{@localDataResize h});
    set(h.Handles.CHKevents,'Value',0);
    localShowEventTable([],[],h)
    localSetTabVisible(es,ed,h,f)
    localFigResize(h.Handles.utabData,[],h.Handles.PNLdata,h.NewPlotPanel.Panel)
     
    set(h.Handles.PNLdata,'Visible','on');
end

function localShowTimeReset(es,ed,h) %#ok<INUSL>

import com.mathworks.toolbox.timeseries.*;

tsguis.tsUniformTimeDlg(h,'open')

function localUpdateTimeStr(es,ed,h)

if ~isempty(h.up) && ishandle(h.up)
    set(h.Handles.LBLCurrentTimeVec,'String',...
        h.Timeseries.TimeInfo.getTimeStr);
end