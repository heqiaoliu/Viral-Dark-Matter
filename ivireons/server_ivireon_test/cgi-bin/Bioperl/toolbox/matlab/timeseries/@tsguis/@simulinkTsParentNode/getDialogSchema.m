function Panel = getDialogSchema(this, manager)
%Render simulinkTsParentNode's viewer panel

%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $ $Date: 2008/12/29 02:11:27 $


import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

% %% Install listeners which update the timeseries table
this.addListeners([...
    handle.listener(this,'ObjectChildAdded',{@localNodeAddedCallback,manager}); ...
    handle.listener(this,'ObjectChildRemoved',{@localRemoveTsNode this manager})]);

set(this.Handles.PNLTsOuter,'Visible','on')
%set(this.Handles.tsTable,'Visible',true)

%% Show the panel
figure(double(manager.Figure))

% Temporary listeners to update table visibility when the enclosing panel
% visibility is modified
p = handle(Panel);
this.addListeners(addlistener(p,'Visible','PostSet',...
    @(es,ed) localSetVisible(es,ed,p)));

localSetVisible([],[],p)

%--------------------------------------------------------------------------
function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;

%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','vis','off'); 

%% Build child timeseries panel
h.Handles.PNLTsOuter = uipanel('Parent',f,'Units','Characters','Title',...
    xlate('Simulink Time Series'),'Visible','on','tag','outer');

PNLtsText = uicontrol('parent',h.Handles.PNLTsOuter,'style','text','String',...
    xlate('Data logged from Simulink models:'),...
    'Units','Characters','pos',[0.01 0.95 0.8 0.04]/10,...
    'HorizontalAlignment','Left','fontweight','normal');

TxtExport = uicontrol('style','Text','Parent',...
    h.Handles.PNLTsOuter,'String','Export','Units','Characters');

BTNexport = uicontrol('style','popupmenu','Parent',...
    h.Handles.PNLTsOuter,'String',{xlate('<Choose Location>'),xlate('To File...'),xlate('To Workspace')},...
    'Units','Characters',...
    'callback',{@localExport h manager});
if ~ismac
   set(BTNexport,'BackgroundColor',[1 1 1]);
end

% BTNexportToWorkspace = uicontrol('style','popupmenu','Parent',...
%     h.Handles.PNLTsOuter,'String','To file...','Units','Characters',...
%     'callback',{@localExportToWorkspace h manager});

BTNextract = uicontrol('Style','Pushbutton','String',xlate('Extract'),'Parent',h.Handles.PNLTsOuter,...
    'Units','Characters','Callback',{@localExtractTs h});
h.Handles.BTNextract = BTNextract;

%%% render all the tables (except uibuttons, which are defined below)
h.tstable;
%set(h.Handles.PNLModelTables,'Units','Characters','Parent',h.Handles.PNLTsOuter);
h.Handles.SelectedTable = []; %initialization for selected table handle

set(h.Handles.PNLTsOuter,'ResizeFcn',...
    {@PNLTsResize, h, PNLtsText, TxtExport, BTNexport, BTNextract});

% PNLTsResize(h.Handles.PNLTsOuter,[],...
%     h.Handles.PNLModelTables,BTNexport,BTNextract)

%% Assign and call the panel resize fcn
set(f,'ResizeFcn',{@localFigResize h.Handles.PNLTsOuter})
localFigResize(f,[],h.Handles.PNLTsOuter)

%--------------------------------------------------------------------------
function localSetVisible(es,ed,h)

children = h.find('-depth',inf,'-isa','uicontainer');
if ~isempty(children)
    set(children,'Visible',get(h,'Visible'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resize function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
function localFigResize(es,ed,outer)
%% Resize callback for simulinkTsparentNode panel 

if strcmpi(get(es,'vis'),'off')
    return
end

fig = ancestor(es,'figure');
%% Components and panels are repositioned relative to the main panel
Ps = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Characters',get(es,'Parent'));

Pc = hgconvertunits(fig,[0 0 1 1],'Normalized','Characters',es);

%% Set the tstable panel to take up all the space above the import panel
%set(outer,'Position',[2 1.4 max(1,mainpnlpos(3)-4) max(1,mainpnlpos(4)-2.4)]);
set(outer,'Position',[0 0 Pc(3:4)]);

%--------------------------------------------------------------------------
function PNLTsResize(es, ed, h, PNLtsText, TxtExport, BTNexport, BTNextract)
% resize function for laying out the tables panel and the buttons
% underneath

if strcmpi(get(es,'vis'),'off')
    return
end

P = get(es,'Position');
htText = 1;
yT = 3;
set(PNLtsText, 'pos', [0 P(4)-yT 40 htText]);

bw = 15; bh = 1.5; 
vm = 0.7; %vertical margin
hm = 1; %horizontal margin
bw2 = 22;

set(BTNextract,'pos',[P(3)-bw2-2*hm vm bw2 bh]);
set(BTNexport,'pos', [P(3)-2*bw-bw2-hm-4 vm bw2+4 bh]);
set(TxtExport,'pos', [P(3)-bw-2*bw2-7*hm-4 vm-0.3 bw bh]);

yl = bh+2*vm; 
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
% extract the selected timeseries members to the parent Time Series node as
% a flat list.

this.extractTsToTree;

%--------------------------------------------------------------------------
function localNodeAddedCallback(es,ed,varargin)
% callback to object child added event which is fired when a nwe child is
% added to the Simulink Time Series parent node.

%es: tsguis.simulinkTsParentNode
%ed: handle.ChildEventData

%es.updatePanel([],'add',ed.Child.Timeseries);
%es.updatePanel;
es.tstable_addnode(ed.Child);

% Have tsstructureevent sent and path cache updated 
manager = varargin{1};
newnodepath = ed.Child.constructNodePath;
ed = tsexplorer.tstreeevent(manager.Root,'add',ed.Child);
manager.Root.fireTsStructureChangeEvent(ed,newnodepath);

%--------------------------------------------------------------------------
function localRemoveTsNode(es,ed,h,manager)
%callback to ObjectChildRemoved event on the @simulinkParentNode

if strcmp(ed.Type,'ObjectChildRemoved')      
    ed.child.removePopup
    h.tstable_removenode(ed.Child);
    ed.child.Handles = [];
end
