function Panel = getDialogSchema(this, manager)
%Simulink TsArray panel layout (tabbed with a plot view)

%   Copyright 2004-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.10 $ $Date: 2010/03/31 18:26:15 $


import javax.swing.*;

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

% %% Install listeners which update the timeseries table
this.addListeners([...
    handle.listener(this,'ObjectChildAdded',@localNodeAddedCallback);
    handle.listener(this,'ObjectChildRemoved',@localRemoveTsNode)]);

%% Add a listener to node renaming
Lrename = handle.listener(this, this.findprop('Label'),'PropertyPostSet',...
    {@localNameChange});
Lrename.CallbackTarget = this;
this.addListeners(Lrename);

set(this.Handles.PNLTsOuter,'Visible','on')

%% Show the panel
figure(double(manager.Figure))

% Temporary listeners to update table visibility when the enclosing panel
% visibility is modified
p = handle(Panel);
this.addListeners(addlistener(p,'Visible','PostSet',...
    @(es,ed) localSetVisible(es,ed,p)));

localSetVisible([],[],this,p)

%--------------------------------------------------------------------------
function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
warning off MATLAB:uitab:visible

%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','vis','off','tag','Bigpanel'); 

%% Build timeseries panel
h.Handles.PNLTsOuter = uipanel('Parent',f,'Units','Normalized','Title',...
    xlate('Simulink Time Series Array'),'tag','outerpanel');

HV = get(thisfig,'HandleVisibility');
% Turn on handle visibility so that tabs don't spawn a new figure
set(thisfig,'HandleVisibility','on'); 
uTabGroup = uitabgroup('Parent',f,'Units','Characters',...
     'selectionChangeCallback',{@localTabSelectionChange h manager f});

set(uTabGroup,'parent',h.Handles.PNLTsOuter);
h.Handles.uTabGroup = uTabGroup;

h.Handles.utabPlot = uitab('Parent',uTabGroup,'Title',xlate('TsArray Plot'),...
    'tag','plottab','Units','Characters');

h.Handles.utabRegular = uitab('Parent',uTabGroup,'Title',xlate('TsArray Members'),...
    'tag','regulartab','Units','Characters');
% There is a bug in uitabgroup where the tabs will show visible even in 
% an invisible uitabgroup. Therefore set the uitabgroup invisible as soon as 
% possible after they are added to minimize flicker. We originally tried
% setting the initial size if the uitabgroup to be very small and then
% expanding it after it was visible but this caused repaint problems in
% JRE 6.0 (see g.531959)
set(uTabGroup,'visible','off');

% draw the plot on the view tabbed panel (h.Handles.utabPlot)
h.syncPlotInfo;

set(thisfig,'HandleVisibility',HV); %restore handle visibility

%% Assign and call the panel resize fcn
set(f,'ResizeFcn',{@localFigResize,h.Handles.uTabGroup});

localFigResize(f,[],h.Handles.uTabGroup);


%--------------------------------------------------------------------------
function localSetVisible(es,ed,h,varargin) %#ok<*INUSL>

child = findobj(h,'type','uitabgroup');
if ~isempty(child)
    set(child,'Visible',get(h,'Visible'));
end

%--------------------------------------------------------------------------
function localSetTableVisible(es,ed,node,f,Table)

%h,uh,h.Handles.PNLModelTables
if strcmp(get(f,'vis'),'on')
    V = get(node.Handles.utabRegular,'vis');
    set(Table,'vis',V);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resize function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
function localFigResize(es,ed,p)
%% Resize callback for simulinkTsparentNode panel 

if strcmpi(get(es,'vis'),'off') ||  strcmpi(get(ancestor(es,'figure'),'vis'),'off') 
    return
end

fig = ancestor(es,'figure');
%% Components and panels are repositioned relative to the main panel

Pc = hgconvertunits(fig,[0 0 1 1],'Normalized','Characters',es);
if Pc(4)<=2
    return
end
set(p,'Position',[0 0 Pc(3)-0.75 Pc(4)-2]);

%--------------------------------------------------------------------------
function localPNLTsResize(es, ed, h, varargin)
% resize function for laying out the tables panel and the buttons
% underneath

P = get(es,'Position');
if strcmpi(get(es,'vis'),'off')
    return
end

TxtExport = varargin{1};
BTNexport = varargin{2};
BTNextract = varargin{3};

yT = 2;
bw = 15; bh = 1.5;
vm = 0.7; %vertical margin
hm = 1; %horizontal margin
bw2 = 22;
yl = bh+2*vm;

if P(4)<=yT || (P(3)-bw-2*bw2-7*hm-4)<=0 || (P(4)-yl-vm-yT)<=0 
    return
end

set(BTNextract,'pos', [P(3)-bw2-2*hm vm bw2 bh]);
set(BTNexport,'pos', [P(3)-2*bw-bw2-hm-4 vm bw2+4 bh]);
set(TxtExport,'pos', [P(3)-bw-2*bw2-7*hm-4 vm-0.3 bw bh]);

set(h.Handles.PNLModelTables, 'pos', [2*hm yl P(3)-4*hm P(4)-yl-vm-yT]);

%--------------------------------------------------------------------------
function localExport(es,ed,this,manager)

Val = get(es,'value');
if Val==1
    return
end

this.exportSelectedObjects(Val,manager);

%reset the popup menu
set(es,'value',1);

%--------------------------------------------------------------------------
function localExtractTs(es,ed,this)
% extract the selected timeseries or DataLogs node

this.extractTsToTree;

%--------------------------------------------------------------------------
function localNodeAddedCallback(es,ed,varargin) %#ok<INUSD>
% callback to object child added event which is fired when a nwe child is
% added to the Simulink Time Series parent node.

es.updatePanel;

%--------------------------------------------------------------------------
function localNameChange(es,ed,varargin)
%update the Title of the tables in this panel and in the root panel list.

%oldTitle = es.Handles.SimTable.getTableName(0);
newTitle = ed.NewValue;

%update my own table
if isfield(es.Handles,'SimTable')
    awtinvoke(es.Handles.SimTable,'setPageTitle(ILjava/lang/String;)',...
        0,java.lang.String(newTitle));
end

function localRemoveTsNode(es,ed)
  
ed.child.removePopup
ed.child.Handles = [];


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
    
    TxtExport = uicontrol('style','Text','Parent',...
        h.Handles.utabRegular,'String','Export','Units','Characters');

    BTNexport = uicontrol('style','popupmenu','Parent',...
        h.Handles.utabRegular,'String',{xlate('<Choose Location>'),xlate('To File...'),xlate('To Workspace')},...
        'Units','Characters',...
        'callback',{@localExport h manager});
    if ~ismac
        set(BTNexport,'BackgroundColor',[1 1 1]);
    end
    BTNextract = uicontrol('Style','Pushbutton','String','Extract','Parent',...
        h.Handles.utabRegular,'Units','Characters','Callback',{@localExtractTs h});
    h.Handles.BTNextract = BTNextract;

    %%% render all the tables (except uibuttons, which are defined below)
    h.tstable;
    %set(h.Handles.PNLModelTables,'Units','Characters','Parent',h.Handles.PNLTsOuter);
    h.Handles.SelectedTable = []; %initialization for selected table handle

    % Temporary listeners to update panel visibility when the uitab visibility
    % is modified 
    uh = handle(h.Handles.utabRegular);
    h.addListeners(handle.listener(uh,uh.findprop('Visible'),'PropertyPostSet',...
        {@localSetTableVisible,h,f,h.Handles.PNLModelTables}));

    set(h.Handles.utabRegular,'ResizeFcn',...
        {@localPNLTsResize, h, TxtExport, BTNexport, BTNextract});
    localPNLTsResize(h.Handles.utabRegular,[],h,TxtExport,BTNexport,BTNextract);
end