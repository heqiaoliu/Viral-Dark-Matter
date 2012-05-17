function generic_listeners(this)
%GENERIC_LISTENERS  Installs generic listeners.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:37:09 $

hgaxes = this.allaxes;

% Install all listeners except the rendering listeners
% Virtual properties implemented by hg.axes
p_scale = [this.findprop('XScale');this.findprop('YScale')];   
p_units = [this.findprop('XUnits');this.findprop('YUnits')];
p_grid = [this.findprop('Grid');this.findprop('GridFcn')];
L1 = [handle.listener(this,p_scale,'PropertyPostSet',@LocalSetScale);...
      handle.listener(this,p_units,'PropertyPreSet',@LocalPreUnitTranform);...
      handle.listener(this,p_units,'PropertyPostSet',@LocalPostUnitTranform);...
      handle.listener(this,p_grid,'PropertyPostSet',{@LocalSetGrid this})];

% Targeted listeners
fig = this.Parent;
L2 = [handle.listener(this,this.findprop('UIContextMenu'),'PropertyPostSet',@LocalSetUIC);...
      handle.listener(this,this.findprop('LimitManager'),'PropertyPostSet',@setlimitmgr);...
      handle.listener(this,this.findprop('Position'),'PropertyPostSet',@setposition);...
      handle.listener(this,this.findprop('NextPlot'),'PropertyPostSet',@LocalSyncNextPlot);...
      handle.listener(this,'ObjectBeingDestroyed',@LocalCleanUp);...
      handle.listener(this,'PostLimitChanged',@updategrid);...
      handle.listener(this,this.findprop('EventManager'),'PropertyPreGet',@LocalDefaultManager)];
set(L2,'CallbackTarget',this);

% Support for CLA (REVISIT)
L3 = LocalCLASupport(this);

L4 = controllibutils.ListenerManager.createVectListeners(hgaxes, ...
    'NextPlot','PostSet',@(es,ed) LocalSyncNextPlot(this,ed));

L5 = controllibutils.ListenerManager.createVectListeners(hgaxes, ...
    'ObjectBeingDestroyed',@(es,ed) LocalDeleteAll(this));

L6 = addlistener(fig, ...
    'SizeChange',@(es,ed) LocalResize(this));

% Store listener handles
this.Listeners.addListeners([L1 ; L2]);
this.Listeners.addListeners(L3);
this.Listeners.addListeners(L4);
this.Listeners.addListeners(L5);
this.Listeners.addListeners(L6);


% Define UpdateFcn for style properties
this.AxesStyle.UpdateFcn = {@LocalSetAxesStyle this hgaxes};
this.TitleStyle.UpdateFcn = {@LocalSetLabelStyle this};
this.XLabelStyle.UpdateFcn = {@LocalSetLabelStyle this};
this.YLabelStyle.UpdateFcn = {@LocalSetLabelStyle this};


%-------------- Local functions -----------------------


function LocalSetAxesStyle(eventsrc,eventdata,h,hax)
% Updates axis style
set(hax,eventsrc.Name,eventdata.NewValue);
if strcmp(eventsrc.Name,'XColor')
   setgridstyle(h,'Color',eventdata.NewValue);
end
% Reapply label style due to HG coupling between XYColor and XYlabel color
setlabels(h)


function LocalSetLabelStyle(eventsrc,eventdata,h)
% Updates title, xlabel, or ylabel style
if ~strcmp(eventsrc.Name,'Location')
   setlabels(h)  % full update because LabelFcn may redirect labels (cf. bodeplot)
end


function LocalSetScale(eventsrc,eventdata)
% Get X or Y scale
h = eventdata.AffectedObject;
axgrid = getaxes(h,'2d');
switch eventsrc.Name
case 'XScale'
   for ct=1:size(axgrid,2)
      set(axgrid(:,ct),'XScale',h.XScale{ct});
   end
case 'YScale'
   for ct=1:size(axgrid,1)
      set(axgrid(ct,:),'YScale',h.YScale{ct});
   end
end    
% Recompute limits (change w/ scale)
h.send('ViewChanged')


function LocalSetGrid(eventsrc,eventdata,this)
% PostSet for Grid and GridFcn
% Clear existing grid
cleargrid(this);
% Update built-in grid state
axgrid = getaxes(this);
if isempty(this.GridFcn)
   set(axgrid(:),'XGrid',this.Grid,'YGrid',this.Grid)
else
   set(axgrid(:),'XGrid','off','YGrid','off')
end
% Trigger limit picker (ensuing PostLimitChanged event will trigger custom grid update)
if (~isempty(this.GridFcn) | strcmp(eventsrc.Name,'GridFcn'))
   this.send('ViewChanged')
end


function LocalSetUIC(h,eventdata)
% Add UI context menu
set(getaxes(h,'2d'),'UIContextMenu',eventdata.NewValue)


function LocalDefaultManager(h,eventdata)
% Installs default event manager
if isempty(h.EventManager)
    h.EventManager = ctrluis.eventmgr(h);
end
    

function LocalDeleteAll(h)
% Callback when data axes deleted: delete @axesgroup object
if ~h.isBeingDestroyed
   delete(h(ishandle(h)))
end


function LocalCleanUp(h,eventdata)
% Clean up when object destroyed
% Delete all HG axes
delete(h.UIContextMenu(ishandle(h.UIContextMenu)))
hgaxes = allaxes(h);
delete(hgaxes(ishghandle(hgaxes)))
h.Listeners.deleteListeners;
h.LimitListeners.deleteListeners;
   

function LocalSyncNextPlot(h,eventdata)
% Aligns NextPlot mode
h.NextPlot = eventdata.NewValue;
hgaxes = h.getaxes('2d');
set(hgaxes(:),'NextPlot',eventdata.NewValue)


function LocalResize(h)
% Resize function (layout manager)
if strcmp(h.LayoutManager,'on')
   setposition(h)
end

%---------------- CLA ------------------------------

function L = LocalCLASupport(h)
% Create invisible lines that trigger callback when deleted by CLA
ax = h.Axes2d(:);
for ct=length(ax):-1:1
   hlines(ct,1) = handle(line(NaN,NaN,'Parent',ax(ct),'Visible','off','UserData',h));
end

L = controllibutils.ListenerManager.createVectListeners(hlines, ...
    'ObjectBeingDestroyed', @LocalCLA);


function LocalCLA(DeletedLine,eventdata)
% Callback when line deleted
ax = handle(DeletedLine.Parent);
if strcmp(get(ax,'BeingDeleted'),'off')  % don't do anything for destroyed axes
   cla(DeletedLine.UserData,ax)
end

%--------------- Units -------------------------

function LocalPreUnitTranform(eventprop,eventdata)
% Converts manual limits when changing units (preset callback)
Axes = eventdata.AffectedObject;
NewUnits = eventdata.NewValue;
PlotAxes = getaxes(Axes,'2d');
% Turn off backdoor listeners
Axes.LimitManager = 'off';
% Update manual limits
switch eventprop.Name
case 'XUnits'
   % REVISIT: set filter should take care of properly formatting XUnits
   XManual = strcmp(Axes.XLimMode,'manual');
   if ischar(Axes.XUnits)
      % No subgrid
      for ct=find(XManual)'
         Xlim = unitconv(get(PlotAxes(1,ct),'Xlim'),Axes.XUnits,NewUnits);
         set(PlotAxes(:,ct),'Xlim',Xlim)
      end
   else
      for ct=find(XManual)'
         ctu = rem(ct-1,length(Axes.XUnits))+1;
         Xlim = unitconv(get(PlotAxes(1,ct),'Xlim'),Axes.XUnits{ctu},NewUnits{ctu});
         set(PlotAxes(:,ct),'Xlim',Xlim)
      end
   end
case 'YUnits'
   % REVISIT: set filter should take care of this
   YManual = strcmp(Axes.YLimMode,'manual');
   if ischar(Axes.YUnits)
      % No subgrid
      for ct=find(YManual)'
         Ylim = unitconv(get(PlotAxes(ct,1),'Ylim'),Axes.YUnits,NewUnits);
         set(PlotAxes(ct,:),'Ylim',Ylim)
      end
   else
      for ct=find(YManual)'
         ctu = rem(ct-1,length(Axes.YUnits))+1;
         Ylim = unitconv(get(PlotAxes(ct,1),'Ylim'),Axes.YUnits{ctu},NewUnits{ctu});
         set(PlotAxes(ct,:),'Ylim',Ylim)
      end
   end
end
Axes.LimitManager = 'on';


function LocalPostUnitTranform(eventprop,eventdata)
% PostSet callback for data transforms (XUnits,...)
% Issue DataChanged event to 
%  1) Force redraw (new units are incorporated when mapping data to the
%     lines' Xdata and Ydata in @view/draw methods)
%  2) Update auto limits (side effect of ensuing ViewChanged event)
% RE: ViewChanged event is not enough here because the lines' XData and YData
%     first needs to be transformed to the new units before updating the limits
%     (otherwise can end up with negative data on log scale)
eventdata.AffectedObject.send('DataChanged')
