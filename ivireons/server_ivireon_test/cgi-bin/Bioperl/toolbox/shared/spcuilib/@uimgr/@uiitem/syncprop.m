function syncprop(dst,src,propName)
%syncprop Sync specified dst prop based on state of src items.
%   Synchronizes the specified property of destination items found in
%   a group, based on the state of items in a source group.
%
%   NOTE:
%   For controlling the visibility of toolbars in a toolbargroup,
%   use syncvic.  Otherwise toolbar order bug-fix will not execute.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/08/14 04:07:32 $

% Add synchronizer for dst items in group
sync(dst, src, ...
    @(dst,dstIdx,src,srcIdx,ev)SyncPropFromState(dst,dstIdx,src,srcIdx,ev,propName));

% ------------------------------------------------------
function SyncPropFromState(dst,dstIdx,src,srcIdx,ev, propName)
%SyncPropFromState

% Set dst visibility according to src state
if isa(ev, 'event.PropertyEvent')
    srcValue = ev.AffectedObject.(ev.Source.Name);
else
    srcValue = ev.NewValue;
end

if isempty(srcValue)
    % Initial vis state
    
    % Find srcIdx'th child
    srcItem = src.down; % get first child
    for i=2:srcIdx
        srcItem = srcItem.right; % get next child
    end
    % Determine the state value to use
    %newValue = srcItem.StateValue;  % 'on' or 'off'
    hWidget = srcItem.hWidget;
    newValue = hWidget.(srcItem.StateName);
else
    % React to a change in src state
    %
    % Dst item property must be an on/off value
    % It is assumed src item uses on/off state (like other sync's)
    % using the same polarity ... so this is simple:
    newValue = srcValue;
end

% Find dstIdx'th child
dstItem = dst.down; % get first dst child
for i=2:dstIdx
    dstItem = dstItem.right; % get next child
end
% Set dst item property:

% Setting property on destination widget
hWidget = dstItem.hWidget;
if ~isempty(hWidget)
    set(hWidget, propName, newValue);
end

% [EOF]
