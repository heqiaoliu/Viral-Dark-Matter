function initialize(this,sisodb)
% Initializes Nichols Plot Editor.

%   Author(s): P. Gahinet, B. Eryilmaz
%   Revised: K. Subbarao 12-6-2001
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.40.4.7 $ $Date: 2010/05/10 16:59:20 $

% Connect editor to object hierarchy
sisodb.connect(this,'down');

% Initialize preference-driven properties
this.FrequencyUnits = sisodb.Preferences.FrequencyUnits;
this.ShowSystemPZ   = sisodb.Preferences.ShowSystemPZ;

% Pass relevant info to editor
this.EventManager = sisodb.EventManager;
this.TextEditor = sisodb.TextEditors(1);
this.ConstraintEditor = sisodb.TextEditors(2);
this.MultiModelFrequency = sisodb.Preferences.getMultiModelFrequency;

% Render editor
LocalRender(this,sisodb.Preferences);

% Add generic listeners
addlisteners(this)

% Add Nichols-specific listeners
% Visibility
L1 = [handle.listener(this, this.findprop('MarginVisible'), ...
      'PropertyPostSet', @LocalSetMarginVis); ...
      handle.listener(this, this.findprop('ShowSystemPZ'), ...
      'PropertyPostSet', @LocalSetPZVis)];
set(L1,'CallbackTarget',this)
% Change in phase units (@axes throws DataChanged event)
Axes = this.Axes;
L2 = handle.listener(Axes, 'DataChanged', {@LocalPostSetUnits this});

L3 = handle.listener(sisodb.Preferences, ...
    sisodb.Preferences.findprop('MultiModelFrequencySelectionData'),...
    'PropertyPostSet', {@LocalUpdateMultiModelFrequency this});


L4 = handle.listener(this, ...
    this.findprop('MultiModelFrequency'),...
    'PropertyPostSet', {@LocalUpdate this});



this.Listeners = [this.Listeners; L1 ; L2; L3; L4];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Initialize Nichols plot HG
% ----------------------------------------------------------------------------%
function LocalRender(Editor, Prefs)

% Get handle to host figure
SISOfig = Editor.root.Figure;
Zlevel = Editor.zlevel('backgroundline');

% Nichols Plot axes
PlotAxes = axes(...
   'Parent', SISOfig, ...
   'Units', 'norm', ...
   'Box', 'on', ...
   'Visible', 'off', ...
   'Xlim', round(unitconv([-360, 0], 'deg', Prefs.PhaseUnits)), ...
   'Ylim', [-40,40], ...
   'HelpTopicKey', 'sisonicholsplot', ...
   'ButtonDownFcn', {@LocalButtonDown Editor});
Editor.setdefaults(Prefs,PlotAxes)

% Set color and zlevel for multimodel display
Editor.UncertainBounds.setColor(Editor.LineStyle.Color.System)
Editor.UncertainBounds.setZLevel(Editor.zlevel('multimodel'));

% Grid options
GridOptions = gridopts('nichols');
GridOptions.Zlevel = Zlevel;

% Create @axes wrapper
% RE: Set limit modes to manual for proper limit conversion when changing units before loading data
Editor.Axes = ctrluis.axes(PlotAxes,...
   'XLabel',sprintf('Open-Loop Phase'),...
   'YLabel',sprintf('Open-Loop Gain (dB)'),...
   'XUnits', Prefs.PhaseUnits, ...
   'XlimSharing','all',...
   'YlimSharing','all',...
   'Grid',Prefs.Grid,...
   'GridFcn',{@LocalPlotGrid Editor},...
   'GridOptions',GridOptions,...
   'LimitFcn',  {@updatelims Editor}, ...
   'LayoutManager','off',...
   'EventManager',Editor.EventManager);

% Horizontal (0 dB) Line
XYdata = infline(-Inf,Inf);
npts = length(XYdata);
AxisLine = line(XYdata,zeros(1,npts),Zlevel(:,ones(1,npts)),...
   'XlimInclude','off','YlimInclude','off','HitTest', 'off', ...
   'Color', Prefs.AxesForegroundColor,'LineStyle', '-.', ...
   'Parent', PlotAxes);
set(AxisLine, 'UserData', ...
   [handle.listener(Editor,Editor.findprop('LabelColor'),...
      'PropertyPostSet', {@LocalSetColor AxisLine});...
   handle.listener(Editor.Axes,Editor.Axes.findprop('Grid'),...
      'PropertyPostSet', {@LocalSetVisible AxisLine})]);

% Build right-click menu
U = Editor.Axes.UIContextMenu;
LocalCreateMenus(Editor,U);
set(get(U, 'children'), 'Enable', 'off')

% Create shadow line specifying portion of Nichols plot to be included in limit picking
% REVISIT: could be incorporated in NicholsPlot as XlimIncludeData
NicholsShadow = line(NaN,NaN,...
   'Parent',PlotAxes, ...
   'LineStyle','none',...
   'HitTest','off',...
   'HandleVisibility','off');

% Build structure of HG handles
Editor.HG = struct(...
   'Compensator', [], ...
   'Margins', [], ...
   'NicholsPlot', [], ...
   'NicholsShadow', NicholsShadow,...
   'System', []);


% ----------------------------------------------------------------------------%
% Plot nichols chart
% ----------------------------------------------------------------------------%
function GridHandles = LocalPlotGrid(Editor)
% Plots Nichols chart
GridHandles = Editor.Axes.plotgrid('ngrid');


% ----------------------------------------------------------------------------%
% Builds right-click menus
% ----------------------------------------------------------------------------%
function LocalCreateMenus(Editor, MenuAnchor)

% Edit pole/zero group
Editor.addmenu(MenuAnchor, 'add');
Editor.addmenu(MenuAnchor, 'delete');
Editor.addmenu(MenuAnchor, 'edit');
% Specifies target gain for editor
h = Editor.addmenu(MenuAnchor,'GainTarget');

% Show menu (Nichols-specific)
h = Editor.addmenu(MenuAnchor,'show');
set(h,'Separator','on')
LocalAddMarginMenu(Editor,h)
%Editor.addmenu(h,'snapshot');
h = Editor.addmenu(MenuAnchor,'multiplemodel');
LocalAddUncertaintyMenu(Editor,h);
Editor.addmenu(MenuAnchor, 'constraint');
% Design Constraints/Grid/Zoom
h = Editor.addmenu(MenuAnchor, 'grid');
set(h, 'Separator', 'on');
set(h, 'Checked', Editor.Axes.Grid);
Editor.addmenu(MenuAnchor, 'zoom');

% Properties
h = Editor.addmenu(MenuAnchor, 'property');
set(h, 'Separator', 'on')



% ----------------------------------------------------------------------------%
% Button down callbacks
% ----------------------------------------------------------------------------%
function LocalButtonDown(hSrc, event, Editor)
Editor.mouseevent('bd',hSrc);


% ----------------------------------------------------------------------------%
% Function: LocalSetColor
% ----------------------------------------------------------------------------%
function LocalSetColor(hSrc,event, AxisLine)
set(AxisLine, 'Color', event.NewValue)


% ----------------------------------------------------------------------------%
% Function: LocalSetVisible
% ----------------------------------------------------------------------------%
function LocalSetVisible(hSrc,eventdata, AxisLine)
if strcmp(eventdata.NewValue,'on')
   set(AxisLine, 'Visible', 'off')
else
   set(AxisLine, 'Visible', 'on')
end


% ----------------------------------------------------------------------------%
% Toggle margin visibility
% ----------------------------------------------------------------------------%
function LocalSetMarginVis(Editor, event)
% Callback when toggling MarginVisible state
% Update visibility of margin objects
if ~isempty(Editor.HG.Margins)
   MarginHandles = struct2cell(Editor.HG.Margins);
   set([MarginHandles{:}],'Visible',Editor.MarginVisible)
end
% Update margin display
showmargin(Editor)
% Refresh limits
updateview(Editor)


% ----------------------------------------------------------------------------%
% Toggle visibility of system poles and zeros
% ----------------------------------------------------------------------------%
function LocalSetPZVis(Editor, event)
if ~strcmp(Editor.EditMode, 'off') & strcmp(Editor.Visible, 'on')
   HG = Editor.HG;
   if strcmp(event.NewValue, 'off')
      set(HG.System, 'Visible', 'off')
   else
      set(HG.System, 'Visible', Editor.Visible)
   end
end


% ----------------------------------------------------------------------------%
% Called when changing units
% ----------------------------------------------------------------------------%
function LocalPostSetUnits(hProp,eventdata,Editor)
% Update labels
setlabels(Editor.Axes);
% Redraw plot 
update(Editor)


% ----------------------------------------------------------------------------%
% Function: LocalAddMarginMenu
% ----------------------------------------------------------------------------%
function LocalAddMarginMenu(Editor,Anchor)
% Adds margin submenu
hs = uimenu(Anchor, 'Label',    sprintf('Stability Margins'), ...
   'Checked',  Editor.MarginVisible, ...
   'Callback', {@MarginMenuCB Editor});
lsnr = handle.listener(Editor, findprop(Editor, 'MarginVisible'), ...
   'PropertyPostSet', {@LocalSetCheck hs});
set(hs, 'UserData', lsnr)  % Anchor listeners for persistency


% ----------------------------------------------------------------------------%
% Function: LocalSetCheck
% ----------------------------------------------------------------------------%
function LocalSetCheck(hProp, event, hMenu)
set(hMenu, 'Checked', event.NewValue);


% ----------------------------------------------------------------------------%
% Function: MarginMenuCB
% Callbacks for Stability Margins submenu (hSrc = menu handle)
% ----------------------------------------------------------------------------%
function MarginMenuCB(hSrc, event, Editor)
if strcmp(get(hSrc, 'Checked'), 'on')
  Editor.MarginVisible = 'off';
else
  Editor.MarginVisible = 'on';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddUncertaintyMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAddUncertaintyMenu(this,h)
% Adds menu items to Uncertainty menu
hb = uimenu(h,'Label',ctrlMsgUtils.message('Control:compDesignTask:strMultiModelBounds'), ...
    'Callback',{@LocalToggleBoundsMenu this});
if isVisible(this.UncertainBounds,'Bounds')
    set(hb,'Checked','on')
else
    set(hb,'Checked','off')
end

hs = uimenu(h,'Label',ctrlMsgUtils.message('Control:compDesignTask:strMultiModelIndividualResponses'), ...
    'Callback',{@LocalToggleSystemsMenu this});
if isVisible(this.UncertainBounds,'Systems')
    set(hs,'Checked','on')
else
    set(hs,'Checked','off')
end

m = struct(...
    'BoundsMenu',hb,...
    'SystemsMenu',hs);
    

L = addlistener(this.UncertainBounds, {'Visible','UncertainType'}, ...
    'PostSet',@(es,ed) LocalUncertainSetCheck(this, m));
set(hb,'UserData',L)  % Anchor listeners for persistency


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalToggleBoundsMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleBoundsMenu(hSrc,event,this)
% Callbacks for Stability Margins submenu (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
    this.UncertainBounds.Visible = 'off';
else
    this.UncertainBounds.UncertainType = 'Bounds';
    this.UncertainBounds.Visible = 'on';
    this.update;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalToggleSystemsMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleSystemsMenu(hSrc,event,this)
% Callbacks for Stability Margins submenu (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
    this.UncertainBounds.Visible = 'off';
else
    this.UncertainBounds.UncertainType = 'Systems';
    this.UncertainBounds.Visible = 'on';
    this.update;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalToggleBoundsMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUncertainSetCheck(this,m)
if isVisible(this.UncertainBounds,'Bounds')
    set(m.BoundsMenu,'Checked','on')
else
    set(m.BoundsMenu,'Checked','off')
end

if isVisible(this.UncertainBounds,'Systems')
    set(m.SystemsMenu,'Checked','on')
else
    set(m.SystemsMenu,'Checked','off')
end

function LocalUpdateMultiModelFrequency(esrc,edata, this)  %#ok<INUSL>
this.MultiModelFrequency = edata.AffectedObject.getMultiModelFrequency;

function LocalUpdate(esrc,edata, this) %#ok<INUSL>
this.update;