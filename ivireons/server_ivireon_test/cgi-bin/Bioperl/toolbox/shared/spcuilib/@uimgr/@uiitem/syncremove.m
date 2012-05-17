function syncremove(h,suppressRerender)
%syncremove Remove sync functions from item.
%   SYNCREMOVE(H) recursively removes sync functions from all children,
%   and re-renders GUI from this point in the hierarchy so that all
%   widget sync-listeners are immediately removed.  Re-rendering will
%   no longer install the sync functions at or below this level.
%
%   SYNCREMOVE(H,true) suppresses re-rendering of the GUI, so that
%   all currently rendered widgets will continue to have sync functions
%   working.  Sync will be fully removed only after unrender/render.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:17 $

% By default, perform unrender/re-render cycle after uninstalling sync
% functions to have sync-removal take immediate effect.  If "true" flag
% passed, skip the re-render cycle.  Sync will persist in the currently
% rendered widgets, but will not be reinstalled on a subsequent render
% operation.
if nargin<2
    suppressRerender=false;
end

% Remove synclist from this entity (item/group)
% SyncList uses lazy instantiation - if it's not instantiated
% for this uiitem, there's nothing to be removed
hSL = h.SyncList;
if ~isempty(h.SyncList)
    remove(hSL);
end

% Remove sync list from each child (if any are present)
hChild = h.down; % get first child
while ~isempty(hChild)
    % Note that .SyncList could be empty, due to lazy instantiation
    % If it's not instantiated, skip ... but keep going with children
    hSL = hChild.SyncList;
    if ~isempty(hSL)
        remove(hSL);
    end
    hChild = hChild.right; % get next child
end

% Perform unrender/re-render cycle at this level in hierarchy
if ~suppressRerender
    h.unrender;  % unrender from here down
    h.up.render; % re-render from parent down
end

% [EOF]
