function this = SisoToolViewer(sisodb)
% Constructor for @SisoToolViewer class.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.9.4.13 $  $Date: 2010/05/10 16:59:31 $

this                  = viewgui.SisoToolViewer;
this.Parent           = sisodb;
LoopData = sisodb.LoopData;

% REVISIT: eliminate when can call parent constructor
initialize(this)
toolbar(this)

% Figure customization
ViewFig = this.Figure;
set(this.Figure,'Renderer','Zbuffer')
set(ViewFig,...
   'Name',sprintf('LTI Viewer for %s',LoopData.Name),...
   'CloseRequestFcn',{@LocalHide this});

StatusCheckBox = uicontrol('Parent',ViewFig,'Style','checkbox','String','Real-Time Update',...
    'TooltipString','Status Bar','Value',strcmpi('on',this.RealTimeEnable),...
    'Callback',{@LocalRealTime this},...
    'Units','character','Position',[0 0.45 23 1.5],'Units','pixels');
HG = this.HG;
HG.StatusCheckBox = StatusCheckBox;
this.HG = HG;

% Add Listener to Track the SisoToolViewer's RealTimeEnable Property
set(this.HG.StatusCheckBox,'UserData',handle.listener(this,this.findprop('RealTimeEnable'),...
     'PropertyPostSet',{@LocalViewRealTime this.HG.StatusCheckBox}));

% Install CS help
ctrlcshelp(ViewFig,sisodb.Figure);

% Customize menus
FigMenus = this.HG.FigureMenu;
set([FigMenus.FileMenu.Import,FigMenus.FileMenu.Export,...
        FigMenus.EditMenu.PlotConfigurations,FigMenus.EditMenu.RefreshSystems,...
        FigMenus.EditMenu.DeleteSystems],'Visible','off')
set(FigMenus.FileMenu.Close,'Callback', {@LocalHide this})
set(FigMenus.EditMenu.LineStyles,'Separator','off')

% Remove undesirable plot types
availViews = this.AvailableViews;
[junk,ia,ib] = intersect({availViews.Alias},{'bodemag','initial','lsim','iopzmap','sigma'});
availViews(ia) = [];
this.AvailableViews = availViews;

% Install listeners (needed below)
addlisteners(this)

% Install listeners for communication between SISO Tool and Viewer
L = [handle.listener(LoopData,'ObjectBeingDestroyed',{@LocalClose this});...
      handle.listener(LoopData,LoopData.findprop('LoopView'),...
      'PropertyPostSet',{@LocalUpdateLoopViews this});...
       handle.listener(sisodb.Preferences,sisodb.Preferences.findprop('PadeOrder'),...
      'PropertyPostSet',{@LocalUpdate this});...
      handle.listener(LoopData,'LoopDataChanged',{@LocalUpdate this});...
      handle.listener(LoopData,'MoveGain',{@LocalMoveGain this});...
      handle.listener(LoopData,'MovePZ',{@LocalMovePZ this});...
      handle.listener(LoopData,'ConfigChanged',{@LocalUpdatePlotNotifications this});...
      handle.listener(this,'ConfigurationChanged',{@LocalUpdatePlotNotifications this}); ... 
      handle.listener(LoopData,LoopData.findprop('Name'),...
      'PropertyPostSet',{@LocalSystemNameCB this})];
set(L,'CallbackTarget',LoopData)
this.addlisteners(L)


L2 = addlistener(this.Figure,'Visible',...
    'PostSet',@(es,ed) LocalUpdate(LoopData,ed,this));
this.addlisteners(L2)

% Create one data source per loop transfer available for
% current configuration
this.setSystems(LoopData)


%%%%%%%%%%%%%%%%%%%%
%%% SystemNameCB %%%
%%%%%%%%%%%%%%%%%%%%
function LocalSystemNameCB(LoopData,eventdata, this)
% Update figure title
set(this.Figure,'Name',sprintf('LTI Viewer for %s',LoopData.Name));

%%%%%%%%%%%%%%%%%
% LocalRealTime %
%%%%%%%%%%%%%%%%%
function LocalRealTime(hSrc,event,this)
% Callback of the check box. Updates the RealTimeEnable property of the
% object.
if get(hSrc,'Value')
    this.RealTimeEnable = 'on';
else
    this.RealTimeEnable = 'off';
end

%%%%%%%%%%%%%%%%%%%%%
% LocalViewRealTime %
%%%%%%%%%%%%%%%%%%%%%
function LocalViewRealTime(hSrc,event,CheckBox)
% Listener Callback of the RealTimeEnable property of the
% object. Will update the CheckBox.
set(CheckBox,'Value',strcmpi('on',event.NewValue));

%%%%%%%%%%%%%%
% LocalClose %
%%%%%%%%%%%%%%
function LocalClose(hSrc,event,this)
% Callback when closing SISO Tool
close(this)

%%%%%%%%%%%%%
% LocalHide %
%%%%%%%%%%%%%
function LocalHide(hSrc,event,this)
% Callback when closing SISO Tool
set(this.Figure,'Visible','off')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlotNotifications %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlotNotifications(LoopData,eventdata, this)
% Update plot notifications
this.updateNotifications;
this.updateMultiModelMenus;


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateLoopViews %
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateLoopViews(LoopData,eventdata,this)
% Update system list when configuration changes
% Get current contents
Contents = getContents(this);
VisViews = find(this.Views(ishandle(this.Views)),'Visible','on');
% Update system list
% RE: Makes all plot invisible for efficiency
this.setSystems(LoopData)
% Restore contents
nsys = length(this.SystemInfo);
for ct=1:length(VisViews)
   VisResp = Contents(ct).VisibleModels;
   set(VisViews(ct).Responses(VisResp(VisResp<=nsys)),'Visible','on')
end
% Restore plot visibility
set(VisViews,'Visible','on')

%%%%%%%%%%%%%%%
% LocalUpdate %
%%%%%%%%%%%%%%%
function LocalUpdate(LoopData,event,this)
% Update LTI Viewer.
ActiveViews = getCurrentViews(this);
if strcmp(get(this.Figure,'Visible'),'off') || isempty(ActiveViews)
   return
end

% Disable limit managers to avoid multiple limit updates
AxGrids = get(ActiveViews,{'AxesGrid'});
AxGrids = cat(1,AxGrids{:});
CurrentState = get(AxGrids,{'LimitManager'});
set(AxGrids,'LimitManager','off')   

% Refresh models
% RE: Not enough to update visible models (hidden models would be out of
%     sync when made visible
for ct=1:length(this.SystemInfo)
   src = this.Systems(ct);
   ModelInfo = this.SystemInfo(ct);  % Recipe for computing model data
   [Model,UncertainModel] = LoopData.getmodel(ModelInfo);
   %Model = LoopData.getmodel(ModelInfo); % Updated model data
   % Update ltisource model
   src.UncertainModel = UncertainModel;
   if isequal(src.Model,Model)
      % Model is up to date when releasing the mouse after dynamic edit.
      % Issue SourceChanged event to force full update in this case. 
      src.send('SourceChanged')
   else
      % If model has changed, let src.Model listener trigger the update
      src.Model = Model;
   end
end

% Refresh each view
% RE: Explicit DRAW to force update when leaving drag-edit mode
set(AxGrids,{'LimitManager'},CurrentState)   
for ax=AxGrids'
   ax.send('ViewChanged')
end

%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(LoopData,eventdata,this)
% Callback to dynamic gain update start/finish events
if strcmp(this.RealTimeEnable,'on') && strcmp(get(this.Figure,'Visible'),'on')
   refreshgain(this,LoopData) 
end
    

%%%%%%%%%%%%%%%%%%%
%%% LocalMovePZ %%%
%%%%%%%%%%%%%%%%%%%
function LocalMovePZ(LoopData,eventdata,this)
% Notifies editors of MOVEPZ:init and MOVEPZ:finish events
if strcmp(this.RealTimeEnable,'on') && strcmp(get(this.Figure,'Visible'),'on')
   refreshpz(this,LoopData)
end