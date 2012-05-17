function p = set_panel(this, p)
%SET_PANEL   PreSet function for the 'panel' property.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 18:01:28 $

% This is faster than STRCMPI
if ~ishghandle(p, 'uipanel') && ~ishghandle(p, 'figure') && ~ishghandle(p, 'uicontainer')
    error(generatemsgid('GUIErr'),'The panel property can only store a UIPANEL, UICONTAINER or a FIGURE object.');
end

% Do this before we create the listeners to avoid accidental firing.
origUnits = get(p, 'Units');    set(p, 'Units', 'Pixels');
pos       = get(p, 'Position'); set(p, 'Units', origUnits);

this.Panel_Listeners = uiservices.addlistener(p, ...
    'ObjectBeingDestroyed', @(h,ev) obd_listener(this));
addlistener(p, 'Visible', 'PostSet', @(h, ev) visible_listener(this));

set(this, 'OldPosition', pos(3:4));

% This doesn't work for uipanels or containers.
%     handle.listener(hp, 'ResizeEvent', @lclupdate); ...

set(p, 'ResizeFcn', @(h,ev) lclupdate(this));

% -------------------------------------------------------------------------
% function lclupdate(this, eventData)
function lclupdate(this)

newPos = getpanelpos(this);
newPos(1:2) = [];

% Only resize if the panel position (width and height) actually changed.
if ~all(this.oldPosition == newPos)
    set(this, 'oldPosition', newPos, 'Invalid', true);
    update(this);
end

% -------------------------------------------------------------------------
function visible_listener(this)

if strcmpi(get(this.Panel, 'Visible'), 'On')
    update(this);
end

% -------------------------------------------------------------------------
function obd_listener(this)

delete(this);

% [EOF]
