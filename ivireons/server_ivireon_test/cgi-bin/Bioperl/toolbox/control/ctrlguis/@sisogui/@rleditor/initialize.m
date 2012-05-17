function initialize(this,sisodb)
%INITIALIZE  Initializes Root Locus Editor.

%   Author(s): P. Gahinet
%   Revised  : K. Subbarao 12-6-2001
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.42.4.8 $ $Date: 2010/05/10 16:59:25 $

% Connect editor to object hierarchy
sisodb.connect(this,'down');

% Initialize preference-driven properties
this.FrequencyUnits = sisodb.Preferences.FrequencyUnits;

% Pass relevant info to editor
this.EventManager = sisodb.EventManager;
this.TextEditor = sisodb.TextEditors(1);
this.ConstraintEditor = sisodb.TextEditors(2);
this.PadeOrder = sisodb.Preferences.PadeOrder;

% Render editor
LocalRender(this,sisodb.Preferences);

% Add generic listeners
addlisteners(this)

% Add root-locus-specific listeners
p = [this.findprop('AxisEqual');...
      this.findprop('FrequencyUnits');...
      this.findprop('GridOptions')];
L = handle.listener(this,p,'PropertyPostSet',@updateview);
set(L,'CallbackTarget',this)
this.Listeners = [this.Listeners ; L];


L = handle.listener(sisodb.Preferences, ...
    sisodb.Preferences.findprop('PadeOrder'),...
    'PropertyPostSet', {@LocalUpdatePadeOrder this});
this.Listeners = [this.Listeners ; L];

L = handle.listener(this, ...
    this.findprop('PadeOrder'),...
    'PropertyPostSet', {@LocalUpdate this});
this.Listeners = [this.Listeners ; L];

%---------------- Local Functions ------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePadeOrder %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePadeOrder(esrc,edata, Editor) %#ok<INUSL>
Editor.PadeOrder = edata.NewValue;

function LocalUpdate(esrc,edata, Editor) %#ok<INUSL>
Editor.update;

%%%%%%%%%%%%%%%%%%%
%%% LocalRender %%%
%%%%%%%%%%%%%%%%%%%
function LocalRender(Editor,Preferences)

SISOfig = Editor.root.Figure; % host figure
Zlevel = Editor.zlevel('backgroundline');

% Plot axes
PlotAxes = axes(...
    'Parent',SISOfig,...
    'Units','norm', ...
    'Visible','off', ...
    'Xlim',[-1,1], ...
    'Ylim',[-1 1],...
    'Box','on',...
    'HelpTopicKey','sisorootlocusplot',...
    'ButtonDownFcn',{@LocalButtonDown Editor});
Editor.setdefaults(Preferences,PlotAxes)

% Set color and zlevel for multimodel display
Editor.UncertainBounds.setZLevel(Editor.zlevel('multimodel'));
Editor.UncertainBounds.setColor(Editor.LineStyle.Color.ClosedLoop)

% Grid options
GridOptions = gridopts('pzmap');
GridOptions.Zlevel = Zlevel;

% Create @axes wrapper
C = getC(Editor);
Editor.Axes = ctrluis.axes(PlotAxes,...
   'XLabel',xlate('Real Axis'),...
   'YLabel',xlate('Imag Axis'),...
   'XlimSharing','all',...
   'YlimSharing','all',...
   'Grid',Preferences.Grid,...
   'GridFcn',{@LocalPlotGrid Editor},...
   'GridOptions',GridOptions,...
   'LimitFcn',  {@updatelims Editor}, ...
   'LayoutManager','off',...
   'EventManager',Editor.EventManager);

% Plot X and Y axis lines
XYdata = infline(-Inf,Inf);
npts = length(XYdata);
AxisLines(1,1) = line(XYdata,zeros(1,npts),Zlevel(:,ones(1,npts)),...
   'Color',Preferences.AxesForegroundColor,...
   'LineStyle',':','Parent',PlotAxes,...
   'HitTest','off','XlimInclude','off','YlimInclude','off');
AxisLines(2,1) = line(zeros(1,npts),XYdata,Zlevel(:,ones(1,npts)),...
   'Color',Preferences.AxesForegroundColor,...
   'LineStyle',':','Parent',PlotAxes,...
   'HitTest','off','XlimInclude','off','YlimInclude','off');
theta = 0:0.062831:2*pi;
Circle = line(cos(theta),sin(theta),Zlevel(:,ones(1,length(theta))),...
   'Color',Preferences.AxesForegroundColor,...
   'Parent',PlotAxes,'LineStyle',':','HitTest','off','Visible','off');
L = handle.listener(Editor,Editor.findprop('LabelColor'),...
   'PropertyPostSet',{@LocalSetColor [AxisLines;Circle]});
set(AxisLines(1),'UserData',L);

% Always include origin
Origin = line([-1 -1 1 1],[-1 1 -1 1],-Zlevel(ones(1,4)),...
   'LineStyle','none','Parent',PlotAxes,'HitTest','off');

% Build right-click menu
U = Editor.Axes.UIContextMenu;
LocalAddMenus(Editor,U);
set(get(U,'children'),'Enable','off')

% Create shadow line specifying root locus portion to be included in limit picking
% REVISIT: could be incorporated in Locus as XlimIncludeData
LocusShadow = line(NaN,NaN,...
   'Parent',PlotAxes, ...
   'LineStyle','none',...
   'HitTest','off',...
   'HandleVisibility','off');

% Data structure of HG objects
% RE: HG.Compensator stores the list of (unique) pole/zero handles
Editor.HG = struct(...
   'AxisLines',AxisLines,...
   'Origin',Origin,...
   'ClosedLoop',[],...
   'Compensator',[],...
   'Locus',[],...
   'LocusShadow',LocusShadow,...
   'System',[],...
   'UnitCircle',Circle);

%-------------------------- Local Functions ------------------------

%%%%%%%%%%%%%%%%%
% LocalPlotGrid %
%%%%%%%%%%%%%%%%%
function GridHandles = LocalPlotGrid(Editor)
% Plots S or Z grid
Ts = Editor.LoopData.Ts;
Axes = Editor.Axes;

% Update grid options
% REVISIT: simplify
Options = Axes.GridOptions;
Options.FrequencyUnits = Editor.FrequencyUnits;
Options.GridLabelType = Editor.GridOptions.GridLabelType;
Options.SampleTime = Ts;
Axes.GridOptions = Options;

% Generate and plot new grid 
if Ts==0
   GridHandles = Axes.plotgrid('sgrid');
else
   GridHandles = Axes.plotgrid('zgrid');
   set(Editor.HG.UnitCircle,'Visible','off') 
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddMenus %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalAddMenus(Editor,MenuAnchor)
% Builds right-click menus

% Edit pole/zero group
addmenu(Editor,MenuAnchor,'add');
addmenu(Editor,MenuAnchor,'delete');
addmenu(Editor,MenuAnchor,'edit');

% Specifies target gain for editor
h = Editor.addmenu(MenuAnchor,'GainTarget');

% Show menu 
% h = Editor.addmenu(MenuAnchor,'show');
% set(h,'Separator','on')
% Editor.addmenu(h,'snapshot');
h = Editor.addmenu(MenuAnchor,'multiplemodel');
set(h,'Separator','on')
LocalAddUncertaintyMenu(Editor,h);
Editor.addmenu(MenuAnchor, 'constraint');

% Design Constraints/Grid/Zoom
h = Editor.addmenu(MenuAnchor, 'grid');
set(h, 'Separator', 'on');
set(h, 'Checked', Editor.Axes.Grid);
Editor.addmenu(MenuAnchor, 'zoom');

% Properties
if usejava('MWT')
    h = addmenu(Editor,MenuAnchor,'property');
    set(h,'Separator','on')
end



%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalButtonDown %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalButtonDown(hSrc,event,Editor)
% Button down callbacks
Editor.mouseevent('bd',hSrc);

%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetColor %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetColor(hSrc,event,AxisLines)
set(AxisLines,'Color',event.NewValue)


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddUncertaintyMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAddUncertaintyMenu(this,h)
% Adds menu items to Uncertainty menu
hb = uimenu(h,'Label',ctrlMsgUtils.message('Control:compDesignTask:strShow'), ...
    'Callback',{@LocalToggleShowMenu this});
if isVisible(this.UncertainBounds)
    set(hb,'Checked','on')
else
    set(hb,'Checked','off')
end

m = struct('ShowMenu',hb);
    

L = addlistener(this.UncertainBounds, {'Visible'}, ...
    'PostSet',@(es,ed) LocalUncertainSetCheck(this, m));
set(hb,'UserData',L)  % Anchor listeners for persistency


function LocalUncertainSetCheck(this,m)
if isVisible(this.UncertainBounds)
    set(m.ShowMenu,'Checked','on')
else
    set(m.ShowMenu,'Checked','off')
end

function LocalToggleShowMenu(hSrc,event,this)
% Callbacks for Stability Margins submenu (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
    this.UncertainBounds.Visible = 'off';
else
    this.UncertainBounds.Visible = 'on';
    this.update;
end

