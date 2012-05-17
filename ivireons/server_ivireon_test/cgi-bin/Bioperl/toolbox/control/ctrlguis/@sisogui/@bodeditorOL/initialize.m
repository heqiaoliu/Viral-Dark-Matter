function initialize(this,sisodb)
%INITIALIZE  Initializes Bode Diagram Editor.

%   Author(s): P. Gahinet
%   Revised:   N. Hickey
%              K. Subbarao 12-6-2001
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.32.4.7 $ $Date: 2010/05/10 16:59:14 $
SISOfig = sisodb.Figure; % host figure

% Connect editor to object hierarchy
sisodb.connect(this,'down');

% Initialize preference-driven properties
this.ShowSystemPZ = sisodb.Preferences.ShowSystemPZ;

% Pass relevant info to editor
this.EventManager = sisodb.EventManager;
this.TextEditor = sisodb.TextEditors(1);
this.ConstraintEditor = sisodb.TextEditors(2);
this.MultiModelFrequency = sisodb.Preferences.getMultiModelFrequency;

% Create editor axes
this.bodeaxes(sisodb.Preferences,SISOfig);

% Set color and zlevel for multimodel display
this.UncertainBounds.setZLevel(this.zlevel('multimodel'));
this.UncertainBounds.setColor(this.LineStyle.Color.System)

% Set HelpTopicKey for Open-Loop Bode axes
PlotAxes = getaxes(this.Axes);
set(PlotAxes, 'HelpTopicKey', 'sisobode');

% Add generic Bode listeners
this.addbodelisteners(sisodb);

% Add @bodeditorOL-specific listeners
L = [handle.listener(this,this.findprop('MarginVisible'),...
      'PropertyPostSet',@LocalSetMarginVis);...
      handle.listener(this,this.findprop('ShowSystemPZ'),...
      'PropertyPostSet',@LocalSetPZVis)];
set(L,'CallbackTarget',this)
this.Listeners = [this.Listeners ; L];

% Create shadow for portion of Bode plot to be included in limit picking
% REVISIT: could be incorporated in Bode plot's as XlimIncludeData
for ct=2:-1:1
   BodeShadow(ct,1) = line(NaN,NaN,'Parent',PlotAxes(ct),'LineStyle','none',...
      'HitTest','off','HandleVisibility','off');
end

% Add @bodeditorOL-specific slots in HG structure
HG = this.HG;
HG.GainMargin = [];
HG.PhaseMargin = [];
HG.BodeShadow = BodeShadow;
this.HG = HG;

% Build right-click menu
U = this.Axes.UIContextMenu;
LocalCreateMenus(this,U);
set(get(U,'children'),'Enable','off')


%-------------------------- Local Functions ------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateMenus %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateMenus(this,MenuAnchor)
% Builds right-click menus

% Edit pole/zero group
this.addmenu(MenuAnchor,'add');
this.addmenu(MenuAnchor,'delete');
this.addmenu(MenuAnchor,'edit');

% Specifies target gain for editor
h = this.addmenu(MenuAnchor,'GainTarget');

% Show menu 
h = this.addmenu(MenuAnchor,'show');
set(h,'Separator','on')
this.bodemenu(h,'magphase');
LocalAddMarginMenu(this,h);  % bodeditorOL-specific item
%this.addmenu(h,'snapshot');

h = this.addmenu(MenuAnchor,'multiplemodel');
LocalAddUncertaintyMenu(this,h);
this.addmenu(MenuAnchor, 'constraint');
% Design Constraints/Grid/Zoom
h = this.addmenu(MenuAnchor, 'grid');
set(h, 'Separator', 'on');
set(h, 'Checked', this.Axes.Grid);
this.addmenu(MenuAnchor, 'zoom');

% Properties
h = this.addmenu(MenuAnchor,'property');
set(h,'Separator','on')



%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCheck %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCheck(hProp,event,hMenu)
% Callbacks for property listeners
set(hMenu,'Checked',event.NewValue);


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetPZVis %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetPZVis(this,event)
% Toggle visibility of system poles and zeros
if ~strcmp(this.EditMode,'off') && strcmp(this.Visible,'on')
    HG = this.HG;
    if strcmp(event.NewValue,'off')
        set([HG.System.Magnitude;HG.System.Phase],'Visible','off')
    else
        set(HG.System.Magnitude,'Visible',this.MagVisible)
        set(HG.System.Phase,'Visible',this.PhaseVisible)
    end
end


%-------------------- Margin-related functions -------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddMarginMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAddMarginMenu(this,h)
% Adds Stability Margins item to Show menu
hs = uimenu(h,'Label',sprintf('Stability Margins'), ...
    'Checked',this.MarginVisible,...
    'Callback',{@LocalToggleMarginMenu this});
L = handle.listener(this,findprop(this,'MarginVisible'),...
    'PropertyPostSet',{@LocalSetCheck hs});
set(h,'UserData',[get(h,'UserData');L])  % Anchor listeners for persistency


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalToggleMarginMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleMarginMenu(hSrc,event,this)
% Callbacks for Stability Margins submenu (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
    this.MarginVisible = 'off';
else
    this.MarginVisible = 'on';
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetMarginVis %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetMarginVis(this,event)
% Callback when toggling MarginVisible state
% Update visibility of margin objects
if ~isempty(this.HG.GainMargin)
   MarginHandles = [struct2cell(this.HG.GainMargin) ; struct2cell(this.HG.PhaseMargin)];
   set([MarginHandles{:}],'Visible',this.MarginVisible)
end
% Update margin display
showmargin(this)
% Refresh limits
updateview(this)

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
%%% LocalUncertainSetCheck %%%
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
