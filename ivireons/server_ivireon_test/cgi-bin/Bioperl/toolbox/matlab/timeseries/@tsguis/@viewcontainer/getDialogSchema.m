function Panel = getDialogSchema(this, manager)

% Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $ $Date: 2008/12/29 02:11:58 $

import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

%% Install listeners 
this.state_listeners;

%% Show the panel
set(this.Handles.PNLViews,'Visible','on')
set(this.Handles.PNLTs,'Visible','on')
figure(double(manager.Figure))

%--------------------------------------------------------------------------
function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
import javax.swing.*;

%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','Visible','off'); 

%% Build view panel
h.Handles.PNLViews = uipanel('Parent',f,'Units','Characters','Title',...
    xlate('Current Plots'),'Position',[0.02 0.52 0.96 0.46]);
h.viewstable
set(h.Handles.PNLviewsTable,'Units','Pixels','Parent',h.Handles.PNLViews);
BTNadd = uicontrol('Style','Pushbutton','String',xlate('Add Plot'),'Parent',h.Handles.PNLViews,...
    'Units','Characters','Callback',{@localAddPlot h manager});
BTNremove = uicontrol('Style','Pushbutton','String',xlate('Remove Plot'),'Parent',h.Handles.PNLViews,...
    'Units','Characters','Callback',{@localRemoveView h});
BTNedit = uicontrol('Style','Pushbutton','String',xlate('Edit Plot...'),'Parent',h.Handles.PNLViews,...
    'Units','Characters','Callback',{@localEditView h});

set(h.Handles.PNLViews,'ResizeFcn',{@PNLViewsResize h.Handles.PNLviewsTable BTNadd BTNremove BTNedit})
PNLViewsResize(h.Handles.PNLViews,[],h.Handles.PNLviewsTable,BTNadd,BTNremove,BTNedit,'Force')

%% List selection listener must update time series table changes status
listSelectionListener = ...
    handle(h.Handles.viewsTable.getSelectionModel,'callbackproperties');
listSelectionListener.ValueChangedCallback = {@localViewSelection h};

%% Build time series panel
h.Handles.PNLTs = uipanel('Parent',f,'Units','Characters','Title', ...
    xlate('Time Series in Selected View'),'Position',[0.02 0.02 0.96 0.46]);

%% React to current selection
localViewSelection([],[],h)

% Set the outermost panel's resize function
set(f,'ResizeFcn',{@localFigResize,h.Handles.PNLViews,h.Handles.PNLTs});

% Exercise the resize function
localFigResize(f,[],h.Handles.PNLViews,h.Handles.PNLTs)

%--------------------------------------------------------------------------
function localSetVisible(es,ed,h)

children = h.find('-depth',inf,'-isa','uicontainer');
if ~isempty(children)
   set(children,'Visible',get(h,'Visible'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resize functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localFigResize(es,ed,PNLViews,PNLTs)

if strcmp(get(es,'Visible'),'off')
    return
end

p = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'characters',get(es,'Parent'));

set(PNLViews,'pos',[2, 1, p(3)-4, p(4)*0.46]);
set(PNLTs,'pos',[2, 0.52*p(4), p(3)-4, p(4)*0.46]);


%-------------------------------------------------------------------------
function PNLViewsResize(es,ed,PNLviewsTable,BTNadd,BTNremove,BTNedit,varargin)

%% Resize fcn for the views pane;

%% No-op if the panel is inivible or if there is no eventData passed with
%% the firing resize event

if nargin<=6 && strcmp(get(get(es,'Parent'),'Visible'),'off') && ...
        isempty(ed)
    return
end

%% Get sizes and margins
pos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'pixels',get(es,'Parent'));
p = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Characters',get(es,'Parent'));
margin = 10;

%% Set positions
bw = 12;
bh = 1.5;

set(BTNadd,'Position',[max(1,p(3)-2-bw) 1 bw bh])
set(BTNremove,'Position',[max(1,p(3)-2.2*bw-4) 1 1.2*bw bh]);
set(BTNedit,'Position',[max(1,p(3)-3.2*bw-6) 1 bw bh]);

btnSize = hgconvertunits(ancestor(es,'figure'),[0 0 bw bh],...
    get(es,'Units'),'pixels',get(es,'Parent'));

set(PNLviewsTable,'Position', ...
    [margin btnSize(4)+2*margin max(1,pos(3)-2*margin) ...
         max(1,pos(4)-(btnSize(4)+2*margin)-2*margin)]);

%--------------------------------------------------------------------------
function localViewSelection(eventSrc,eventData,h)

%% Find the selected view and create a listener to track changes in its
%% member time series
if ~ishandle(h) || isempty(h.Dialog) || ~ishghandle(h.Dialog) || ...
        strcmp(get(ancestor(h.Dialog,'figure'),'BeingDeleted'),'on')
    return
end
selRow = h.Handles.viewsTable.getSelectedRow;
if ~isempty(eventData) && (eventData.getFirstIndex<0 || eventData.getValueIsAdjusting)
    return
end

if selRow+1>0
    viewTableData = cell(h.Handles.viewsTable.getModel.getData);
    selectedView = h.getChildren('Label',viewTableData{selRow+1,1});
else
    selectedView = [];
end

%% Refresh the time series table
tstable(h,selectedView)

%--------------------------------------------------------------------------
function localRemoveView(eventSrc,eventData,h)

%% Remove view button callback which detaches the view node (whose
%% listeners then close the view etc.)
selRow = h.Handles.viewsTable.getSelectedRow+1;
tableData = cell(h.Handles.viewsTable.getModel.getData);
if selRow>0
    thisview = h.getChildren('Label',tableData{selRow,1});
    h.removeNode(thisview);
end

%--------------------------------------------------------------------------
function localEditView(eventSrc,eventData,h)

%% Edit view button callback which detaches Opens the PlotTool 
%% Property Editor
selRow = h.Handles.viewsTable.getSelectedRow+1;
if selRow>0
    tableData = cell(h.Handles.viewsTable.getModel.getData);
    thisview = h.getChildren('Label',tableData{selRow,1});
    if ~isempty(thisview.Plot) && ishandle(thisview.Plot)
        propedit(thisview.Plot.AxesGrid.Parent);
         % Reset invalid ScribeFigSavedState to prevent hourglass
        if isappdata(ancestor(thisview.Plot.AxesGrid.Parent,'figure'),'ScribeFigSavedState')
             state = getappdata(ancestor(thisview.Plot.AxesGrid.Parent,'figure'),...
                'ScribeFigSavedState');
             if isfield(state,'Pointer')
                 state.Pointer = 'arrow';
                 setappdata(ancestor(thisview.Plot.AxesGrid.Parent,'figure'),...
                     'ScribeFigSavedState',state);
             end
        end
        plotedit(ancestor(thisview.Plot.AxesGrid.Parent,'figure'),'off');
    end
end

function localAddPlot(es,ed,h,manager)

newview = h.addplot(manager);
% Make empty fig visible and dock it 
if ~isempty(h.getRoot.TsViewer.MDIGroupName)
    set(ancestor(newview.Figure,'Figure'),'WindowStyle','docked')
end
newview.maybeDockFig;
set(newview.Figure,'Visible','on');
