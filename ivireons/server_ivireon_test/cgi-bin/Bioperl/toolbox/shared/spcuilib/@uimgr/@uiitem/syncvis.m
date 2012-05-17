function syncvis(dst,src)
%syncvis Sync visibility of dst based on state of src items.
%   Synchronizes the visibility of destination items found in
%   a group, based on the state of items in a source group.
%
%   This can be used for controlling the visibility of toolbars
%   in a toolbargroup, based on the state of menu-toggles in a
%   menugroup.  In this case, use syncprop(dst,src,'Visible').
%
%   Use this method when synchronizing visibility of toolbars,
%   so that toolbar bug-fix will execute properly.  This sets
%   visibility on destination uiitem, not child widget directly.
%   Otherwise caller can use syncprop() to execute sync on
%   destination widget.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/08/14 04:07:33 $

% Add synchronizer for dst items in group
sync(dst, src, @SyncVisFromState);

% ------------------------------------------------------
function SyncVisFromState(dst,dstIdx,src,srcIdx,ev)
%SyncVisFromState Syncs destination uiitem visibility.

% Set dst visibility according to src state
if isa(ev, 'event.PropertyEvent')
    srcValue = ev.AffectedObject.(ev.Source.Name);
else
    srcValue = ev.NewValue;
end

if isempty(srcValue)
    % Initial vis state
    
	% src is a group even if it has a widgetFcn
	%   (we don't derive sync from a group widget,
	%    i.e., no state on a parent submenu)
    %   find srcIdx'th child
	srcIsItem = ~src.isGroup;
	if srcIsItem
		srcItem = src;
		% if srcIdx~=1
		%    assert('srcIdx must be 1 for sync on a src item');
        % end
	else
		srcItem = src.down; % get first child
		for i=2:srcIdx
			srcItem = srcItem.right; % get next child
		end
	end
    % Determine the state value to use
    %newValue = srcItem.StateValue;  % 'on' or 'off'
	hWidget = srcItem.hWidget;
	newValue = hWidget.(srcItem.StateName);
else
    % React to a change in src state
    %
    % Dst item vis is an on/off value
    % It is assumed src item uses on/off state (like other sync's)
    % using the same polarity ... so this is simple:
    newValue = srcValue;
end

% Find dstIdx'th child
dstIsItem = ~dst.isGroup || dst.TreatAsItemForSyncDst; % ~isempty(dst.WidgetFcn);
if dstIsItem
	dstItem = dst;
	% if dstIdx~=1
	%    assert('dstIdx must be 1 for sync on a dst item');
	% end
else
	dstItem = dst.down; % get first dst child
	for i=2:dstIdx
		dstItem = dstItem.right; % get next child
	end
end

% Set dst uiitem visibility:
% Setting property on uiitem, not widget
% This is needed for visibility changes,
%  so that toolbar bug fix executes.
%
dstItem.Visible = newValue;

% [EOF]
