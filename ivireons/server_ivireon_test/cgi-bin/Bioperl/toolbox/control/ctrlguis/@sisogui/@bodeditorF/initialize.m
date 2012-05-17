function initialize(this,sisodb)
%INITIALIZE  Initializes Bode Diagram this.

%   Author(s): P. Gahinet
%   Revised: K. Subbarao 12-6-2001
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.18.4.6 $ $Date: 2010/05/10 16:59:11 $
SISOfig = sisodb.Figure; % host figure

% Connect editor to object hierarchy
sisodb.connect(this,'down');

% Pass relevant info to editor
this.EventManager = sisodb.EventManager;
this.TextEditor = sisodb.TextEditors(1);
this.ConstraintEditor = sisodb.TextEditors(2);
this.MultiModelFrequency = sisodb.Preferences.getMultiModelFrequency;

% Render editor
this.bodeaxes(sisodb.Preferences,SISOfig);

% Set color and zlevel for multimodel display
this.UncertainBounds.setColor(this.LineStyle.Color.ClosedLoop)
this.UncertainBounds.setZLevel(this.zlevel('multimodel'));

% Set HelpTopicKey for PreFilter Bode  axes
PlotAxes = getaxes(this.Axes);
set(PlotAxes, 'HelpTopicKey', 'sisoprefilter');

% Add generic Bode listeners
this.addbodelisteners(sisodb);

% Add listeners specific to @bodeditorF
L = handle.listener(this,this.findprop('ClosedLoopVisible'),...
      'PropertyPostSet',@LocalSetCLVis);
set(L,'CallbackTarget',this)
this.Listeners = [this.Listeners ; L];

% Create shadows for Bode plot portions to be included in limit picking
% REVISIT: could be incorporated in Bode plot's as XlimIncludeData
for ct=4:-1:1
   BodeShadow(ct) = line(NaN,NaN,'Parent',PlotAxes(1+rem(ct-1,2)),...
      'LineStyle','none','HitTest','off','HandleVisibility','off');
end
HG = this.HG;
HG.BodeShadow = reshape(BodeShadow,[2 2]);
this.HG = HG;

% Build right-click menu
U = this.Axes.UIContextMenu;
LocalCreateMenus(this,U);
set(get(U,'children'),'Enable','off')


%-------------------------- Local Functions ------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateMenus %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateMenus(this,MenuAnchor,EditFlag)
% Builds right-click menus

% Edit pole/zero group
this.addmenu(MenuAnchor,'add');
this.addmenu(MenuAnchor,'delete');
this.addmenu(MenuAnchor,'edit');
% Select compenstator to edit for closed-loop
h = this.addmenu(MenuAnchor,'Compensator');

% Show menu 
h = this.addmenu(MenuAnchor,'show');
set(h,'Separator','on')
this.bodemenu(h,'magphase');
%this.addmenu(h,'snapshot');

h = this.addmenu(MenuAnchor,'multiplemodel');
LocalAddUncertaintyMenu(this,h)
this.addmenu(MenuAnchor, 'constraint');
% Design Constraints/Grid/Zoom
h =  this.addmenu(MenuAnchor, 'grid');
set(h, 'Separator', 'on')
set(h, 'Checked', this.Axes.Grid);
this.addmenu(MenuAnchor, 'zoom');

% Properties
if usejava('MWT')
   h = this.addmenu(MenuAnchor,'property');
   set(h,'Separator','on')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddClosedLoop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = LocalAddClosedLoop(this,h)
% Adds Closed Loop item to Show menu

hs = uimenu(h,'Label',sprintf('Closed Loop'), ...
   'Checked',this.ClosedLoopVisible,...
   'Callback',{@LocalShowClosedLoop this});
lsnr = handle.listener(this,findprop(this,'ClosedLoopVisible'),...
   'PropertyPostSet',{@LocalSetCheck hs});

set(h,'UserData',[get(h,'UserData');lsnr])  % Anchor listeners for persistency


%-------------------- Callback functions -------------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCheck %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCheck(hProp,event,hMenu)
% Callbacks for property listeners
set(hMenu,'Checked',event.NewValue);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowClosedLoop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowClosedLoop(hSrc,event,this)
% Callbacks for Closed Loop submenu (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
   this.ClosedLoopVisible = 'off';
else
   this.ClosedLoopVisible = 'on';
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCLVis %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCLVis(this,event)
if strcmp(this.ClosedLoopVisible,'on')
   % Redraw to show closed-loop response
   update(this)
else
   % Hide closed-loop plot
   % REVISIT: simplify
   HG = this.HG;
   if size(HG.BodePlot,2)>1 && all(ishandle(HG.BodePlot(:,2)))
      delete(HG.BodePlot(:,2))
      HG.BodePlot = HG.BodePlot(:,1);
      this.HG = HG;
   end
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
% Callbacks for submenu (hSrc = menu handle)
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
% Callbacks for submenu (hSrc = menu handle)
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
