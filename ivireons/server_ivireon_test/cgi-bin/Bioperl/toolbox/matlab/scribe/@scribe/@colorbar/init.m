function init(h)
%init Initializes all listeners for colorbar

%   Copyright 1984-2007 The MathWorks, Inc.

% add listeners to figure

ax = double(h.Axes);
fig = ancestor(h, 'figure');

set(double(h),'ButtonDownFcn',@resetCurrentAxes);
%set up listeners-----------------------------------------
l= handle.listener(h,h.findprop('Location'),...
                   'PropertyPostSet',{@changedLocation,ax});  
l(end+1) = handle.listener(h,h.findprop('OrientationI'),...
                   'PropertyPostSet',{@changedOrientationI});
lpos = handle.listener(h,h.findprop('Position'),...
                   'PropertyPostSet',{@changedPos,h,'position'});
l(end+1)= lpos;
lposouter = handle.listener(h,h.findprop('OuterPosition'),...
                            'PropertyPostSet',{@changedPos,h,'outerposition'});
l(end+1)= lposouter;
  
posListeners = [lpos, lposouter];
l(end+1)= handle.listener(h,h.findprop('Units'),...
                          'PropertyPreSet',{@changedUnits,h,'off',posListeners});
l(end+1)= handle.listener(h,h.findprop('Units'),...
                          'PropertyPostSet',{@changedUnits,h,'on',posListeners});
l(end+1)= handle.listener(h,h.findprop('EdgeColor'),...
                          'PropertyPostSet',@changedEdgeColor); 
l(end+1)= handle.listener(h,h.findprop('Visible'),...
                          'PropertyPostSet',@changedVisibility);
l(end+1)= handle.listener(h,[h.findprop('XLim'),h.findprop('YLim')],...
                          'PropertyPostSet',@changedLimits);              
l(end+1)= handle.listener(h,h.findprop('XAxisLocation'),...
                          'PropertyPostSet',@changedXAxisLocation);              
l(end+1)= handle.listener(h,h.findprop('YAxisLocation'),...
                          'PropertyPostSet',@changedYAxisLocation);              
l(end+1) = handle.listener(handle(ax),findprop(handle(ax),'CLim'),...
    'PropertyPostSet',{@localResetColorBarProperties,fig,ax,h});
l(end+1) = handle.listener(handle(fig),findprop(handle(fig),'Colormap'),...
    'PropertyPostSet',{@localResetColorBarProperties,fig,ax,h});
hProps(3) = findprop(h,'EdgeColor');
hProps(2) = findprop(h,'YColor');
hProps(1) = findprop(h,'XColor');
l(end+1) = handle.listener(h,hProps,'PropertyPostSet',@localChangeAxisColor);
                      
h.PropertyListeners = l;  
l = handle.listener(h,'ObjectBeingDestroyed',{@colorbarDeleted,h});
h.DeleteListener = l;

methods(h,'set_contextmenu','on');
h.methods('startlisteners');  % installs peer axis listeners
  
if ~isempty(ax)
  % set correct state of cbar toggle and menuitem
  graph2dhelper('updateLegendMenuToolbar', [], [], double(h.Axes));

  legendcolorbarlayout(ax,'on')
  legendcolorbarlayout(ax,'addToLayoutList',double(h))
  legendcolorbarlayout(ax,'layout')
end

h.methods('auto_adjust_colors');

%----------------------------------------------------------------------%
function localChangeAxisColor(hProp,eventData)
propName = [hProp.Name 'Mode'];
set(eventData.AffectedObject,propName,'manual');

%----------------------------------------------------------------------%
% Callback fired when EdgeColor changes. Updates X and Y Color.
function changedEdgeColor(hProp,eventData)
h=eventData.affectedObject;
c = get(h,'EdgeColor');
set(h.PropertyListeners,'Enable','off');
if strcmpi(get(h,'XColorMode'),'auto')
    set(h,'XColor',c);
end
if strcmpi(get(h,'YColorMode'),'auto')
    set(h,'YColor',c);
end
set(h.PropertyListeners,'Enable','on');

%----------------------------------------------------------------------%
% Callback fired when Location changes. Sets orientation and does layout.
function changedLocation(hProp,eventData,ax)
cbar = eventData.affectedObject;
% Run the layout routine every time Location changes
% We don't need to run setConfiguration unless the orientation has changed
if ~isempty(ax)
  legendcolorbarlayout(ax,'removeFromLayoutList',double(cbar))
  legendcolorbarlayout(ax,'addToLayoutList',double(cbar))
  legendcolorbarlayout(ax,'layout');
end

%----------------------------------------------------------------------%
% Callback fired when OrientationI changes.  Runs setConfiguration because
% colorbar is dirty.
function changedOrientationI(hProp,eventData)
cbar = eventData.affectedObject;
methods(cbar,'setConfiguration', cbar.Axes);

%----------------------------------------------------------------------%
% Callback fired when Units change Pre and Post to enable/disable
% position listeners
function changedUnits(hProp,eventData,h,state,arrlisteners)
set(arrlisteners,'enable',state)

%----------------------------------------------------------------------%
% Callback fired when Position or OuterPosition changes. Enters
% manual positioning mode so that auto-layout doesn't move the object.
function changedPos(hProp,eventData,h,prop) %#ok
if strcmp(get(h,'ActivePositionProperty'),prop) && ...
      (isempty(h.Axes) || isempty(getappdata(h.Axes,'inLayout')))
  set(h,'Location','manual')
end

%----------------------------------------------------------------%
% Callback fired when visibility of the colorbar (axes) changes. 
% Change visibility of contents also appropriately
function changedVisibility(hProp,eventData) %#ok
h=eventData.affectedObject;
ax = double(h);
vis = get(ax,'Visible');
set(ax,'ContentsVisible',vis);

%----------------------------------------------------------------%
% Callback fired when the X/Y Limit of the colorbar is changed. 
% Set the colormaplim appdata on the image appropriately
function changedLimits(hProp,eventData)
h=eventData.affectedObject;
ax = double(h);
img = findobj(ax,'Type','image');

switch hProp.Name
    case 'XLim'
        if ~isempty(get(ax, 'XTick'))
            setappdata(img,'colormaplim',eventData.NewValue);
        end
    case 'YLim'
        if ~isempty(get(ax, 'YTick'))
            setappdata(img,'colormaplim',eventData.NewValue);
        end
end

%----------------------------------------------------------------------%
% Callback fired when colorbar XAxisLocation changes
function changedXAxisLocation(hProp, eventData)
h=eventData.affectedObject;
setprivateprop(h,'OrientationI',['Horizontal' eventData.NewValue]);

%----------------------------------------------------------------------%
% Callback fired when colorbar YAxisLocation changes
function changedYAxisLocation(hProp, eventData)
h=eventData.affectedObject;
setprivateprop(h,'OrientationI',['Vertical' eventData.NewValue]);

%----------------------------------------------------------------------%
% Callback fired on ObjectBeingDeleted. Updates toolbar toggle
% does layouts of peer axis.
function colorbarDeleted(hProp,eventData,h)

uic = get(h,'UIContextMenu');
if ishandle(uic)
  delete(uic);
end
if ishandle(double(h)) && ...
      ishandle(get(double(h),'parent')) && ...
      ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on') &&...
      ~isempty(h.Axes)
  graph2dhelper('updateLegendMenuToolbar', [], [], double(h.Axes));
  legendcolorbarlayout(double(h.Axes),'removeFromLayoutList',double(h))
  legendcolorbarlayout(double(h.Axes),'layout')
end

%----------------------------------------------------------------------%
function resetCurrentAxes(hSrc, evdata)
dh = double(hSrc);
fig = ancestor(dh,'figure');
if get(fig,'CurrentAxes') == dh
  set(fig,'CurrentAxes',double(get(hSrc,'Axes')));
end

%----------------------------------------------------------------------%
function localResetColorBarProperties(obj,evd,fig,ax,cbar)
% Callback to signal to the colorbar to reset its properties if the "CLim"
% property of the axes changes, or the "Colormap" property of the figure
% changes.

% Disable the listeners to prevent conflicts
hList = cbar.PropertyListeners;
enableState = get(hList,'Enable');
set(hList,'Enable','off');

% Delete the image, it will be reconstructed.
if ishandle(cbar.Image)
    delete(cbar.Image);
    cbar.Image = [];
else
    img = findobj(double(cbar),'Type','image');
    delete(img);
end

cbar.methods('initialize_colorbar_properties',fig,ax);
% setConfiguration will update the colorbar X/YLim (for axes CLim changes)
% setConfiguration will update the colorbar's image (for figure Colormap changes)
cbar.methods('setConfiguration');

% Restore the listeners
for i = 1:length(hList)
    set(hList(i),'Enable',enableState{i});
end

function changedTickOrAxisLocation(obj, evd, h)
set(h,'Location','manual');