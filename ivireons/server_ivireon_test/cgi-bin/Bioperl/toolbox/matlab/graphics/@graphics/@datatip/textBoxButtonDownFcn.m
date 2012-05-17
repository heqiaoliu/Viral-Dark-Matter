function textBoxButtonDownFcn(hDatatip,eventSrc,eventData,hThis,hFig)
% This gets called when the user clicks on the datatip
% textbox (not to be confused with the datatip marker)

% Copyright 2005-2007 The MathWorks, Inc.

% HG timing may get us into a state where this
% function is called but the input instance is stale.

if ~ishandle(hThis)
    return;
end

sel_type = get(hFig,'SelectionType');

%localDebug(hThis,'@datatip\datatip.m : start localTextBoxButtonDownFcn',sel_type);

switch sel_type
    case 'normal' % left click
        % Place the datatip in a moveable orientation mode
    case 'open' % double click
        % do nothing
        return;
    case 'alt' % right click
        % do nothing
        %Make the datatip current
        makeCurrent(hThis);
        return;
    case 'extend' % center click
        % do nothing
        return;
end

% The behavior will be slightly different depending on whether the mode is
% active:
obj = getCallbackObj(hThis,hFig);

origState.origMotionFcn = get(obj,'WindowButtonMotionFcn');
origState.origUpFcn = get(obj,'WindowButtonUpFcn');
origState.Pointer = get(hFig,'Pointer');
set(obj,'WindowButtonMotionFcn',{@localTextBoxMotionFcn,hThis,obj});
set(obj,'WindowButtonUpFcn',{@localTextBoxButtonUpFcn,hThis,obj,origState});
set(hFig,'Pointer','fleur');

% Bring datatip to foreground
movetofront(hThis);

% Set to double buffer to avoid flickering
hThis.OriginalDoubleBufferState = get(hFig,'DoubleBuffer');
set(hFig,'DoubleBuffer','on');

% Highlite datatip
highlite(hThis,'on');

%Make the datatip current
makeCurrent(hThis);

%localDebug(hThis,'@datatip\datatip.m : end localTextBoxButtonDownFcn');

%-------------------------------------------------%
function localTextBoxMotionFcn(hTextBox,evd,hThis,obj)
% This gets called while the user mouse drags the
% datatip textbox around.

if ~ishandle(hThis)
    return;
end

% Get needed handles
hAxes = get(hThis,'HostAxes');
hFig = ancestor(hAxes,'figure');
hHost = hThis.Host;

if isa(obj,'uitools.uimode')
    % Get current point in pixels
    curr_units = hgconvertunits(hFig,[0 0 evd.CurrentPoint],...
        'pixels',get(hFig,'Units'),hFig);
    curr_units = curr_units(3:4);
    set(hFig,'CurrentPoint',curr_units);
end

%localDebug(hThis,'@datatip\datatip.m : start localTextBoxMotionFcn');

% Get mouse position in points
mouse_pos = localGetAxesMousePointsPosition(hAxes);
xm = mouse_pos(1);
ym = mouse_pos(2);

% Get datatip position in points
datatip_pos = localGetDatatipPointsPosition(hThis);
xd = datatip_pos(1);
yd = datatip_pos(2);

% Determine orientation
if xm>=xd && ym>=yd
    hThis.Orientation = 'top-right';
elseif xm>=xd && ym<yd
    hThis.Orientation = 'bottom-right';
elseif xm<xd && ym>=yd
    hThis.Orientation = 'top-left';
else
    hThis.Orientation = 'bottom-left';
end

%localDebug(hThis,'@datatip\datatip.m : end localTextBoxMotionFcn');

%-------------------------------------------------%
function [mouse_pos] = localGetAxesMousePointsPosition(hAxes)
% Get mouse points position relative to axes

%localDebug(hThis,'@datatip\datatip.m : start localGetAxesMousePointsPosition');

% Get mouse points position relative to figure
hFig = ancestor(hAxes,'figure');
mouse_pos = hgconvertunits(hFig,[0 0 get(hFig,'CurrentPoint')],...
    get(hFig,'Units'),'points',0);
mouse_pos = mouse_pos(3:4);

% Get axes points position
axes_pos = hgconvertunits(hFig,get(hAxes,'Position'),...
    get(hAxes,'Units'),'points',get(hAxes,'Parent'));

% Get mouse position relative to axes position
mouse_pos = mouse_pos(1:2) - axes_pos(1:2);

%localDebug(hThis,'@datatip\datatip.m : end localGetAxesMousePointsPosition');


%-------------------------------------------------%
function localTextBoxButtonUpFcn(hTextBox,evd,hThis,obj,origState)
% This gets called when the user mouse clicks up
% after dragging the datatip textbox around.

%localDebug(hThis,'@datatip\datatip.m : start localTextBoxButtonUpFcn');

hFig = ancestor(get(hThis,'HostAxes'),'figure');

%Restore the callbacks
set(obj,'WindowButtonMotionFcn',origState.origMotionFcn);
set(obj,'WindowButtonUpFcn',origState.origUpFcn);
set(hFig,'Pointer',origState.Pointer);

% Restore figure properties
set(hFig,'doublebuffer',hThis.OriginalDoubleBufferState);

% Remove datatip highlite
highlite(hThis,'off');

%localDebug(hThis,'@datatip\datatip.m : end localTextBoxButtonUpFcn');

%-------------------------------------------------%
function [points_pos] = localGetDatatipPointsPosition(hThis)

%localDebug(hThis,'@datatip\datatip.m : start localGetDatatipPointsPosition');

hMarker = hThis.MarkerHandle;
hText = hThis.TextBoxHandle;
%Prevent update function from firing too much:
setappdata(hThis.HostAxes,'datatip_fireDataTipUpdate',false);
orig_text_pos = get(hText,'Position');
orig_text_units = get(hText,'Units');
rmappdata(hThis.HostAxes,'datatip_fireDataTipUpdate');

% Ideally we can transform from data to points via HG
% but currently there is no hook. We can get this
% transform indirectly via a text object.
hText.Units = 'data';
% Do not use hThis.Position here, that property may be temporarily stale
% and is intended for client code only
pos = hThis.DataCursorHandle.Position;
if isempty(pos)
    error('MATLAB:graphics:datatip:emptyPosition','Data cursor position is empty');
end
hText.Position = pos;
hText.Units = 'points';
points_pos = hText.Position;

% Restore text object state
hText.Units = orig_text_units;
hText.Position = orig_text_pos;

%localDebug(hThis,'@datatip\datatip.m : end
%localGetDatatipPointsPosition');
