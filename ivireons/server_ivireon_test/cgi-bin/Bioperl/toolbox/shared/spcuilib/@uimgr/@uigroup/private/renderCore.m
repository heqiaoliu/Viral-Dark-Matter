function renderCore(h,hPropParent)
%RENDERCORE Render a group (no unrender).
%  Renders all unrendered items and groups.
%  No un-rendering occurs here.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/04/27 19:55:06 $

% Definitions for usage of group parent handles:
% .GraphicalParent
%    - is passed as the argument to each WidgetFcn

% It is assumed that Visible and Enable have propagated
% whenever those properties have changed.
% There's nothing further to do here, aside from using
% those states during final uiitem rendering.

% Sort visible children based on placement
% (No children are rendered, but some have their visible
%  property set to 'on' --- it's these children that are
%  of interest here)
% true flag -> ignore rendered state during computation
%              (all children are unrendered at this point)
%
% Set separator state on each visible uiitem
% (regardless of whether it's rendered)
% Pass flag to ignore visibility - forcing update to separator
% state of every child
%
% args: don't descend, ignoreRenderedState
enforceItemSeparators(h,false,true);

% Must recompute child order for rendering
% The order computed for separators considers visibility of items
% For rendering, we explicitly disregard visibility (inf flag):
% meaning, we render items even if invisible (it's just that their
% widgets are set to invisible!)
%
% args: ignore rendered state (true), ignore all vis (inf)
childObjOrder = computeChildOrder(h,true,inf);

% How we establish graphical parent
%
% First, if .Parent is explicitly set by caller, we use that with
% highest priority.
%
% Failing that, we get a graphical parent handle propagated down to us.
% This might be useful.  The different cases of child types demand
% different actions:
%   1) if graphical parent handle is empty,
%      we establish a widget-specific reasonable parent
%      using a class-specific overload (renderPre)
%   2) if graphical parent is valid,
%      we use it.  But, the parent may be, say, a figure, while
%      the child is a button.  This won't work.  This must be
%      translated through a widget-specific adaptation
%      again, using renderPre
%        => renderPre accepts a graphical parent arg,
%           and it handles no arg, an empty arg, or a handle
%           If it's a handle, it checks if it's reasonable
%           Ex: button renderPre
%               handle: toolbar, outcome: uses it
%               handle: figure, outcome: new toolbar
%               handle: other/menu, outcome: error

% First shot at a graphical parent:
%   .Parent is an optional manual override that is user-specified
%   and takes highest priority
%
% It is the handle that is to be used as the parent for the
% group widget itself.  It is used for the group children ONLY
% if the group has no widget itself; otherwise, the group widget
% becomes the parent handle for the children.
if ~isempty(h.Parent)
    % .Parent takes top priority for changing .GraphicalParent
    h.GraphicalParent = h.Parent;
end

% Perform any initial render tasks prior to rendering children,
% including installing synclist items
%
% This may also attempt to set .GraphicalParent, if not already set
if nargin<2
    hPropParent = [];
end
h.renderPre(hPropParent);

% render the group widget
% We call superclass render() method [protected]
% The way we must do that here is to call a renamed version
%
render_widget(h);

% Determine graphical parent for children
% If this group renders its own widget,
% that's the graphical parent for the children.
%
hWidget = h.hWidget;
if ~isempty(hWidget)
    childGraphicalParent = hWidget;
else
    childGraphicalParent = h.GraphicalParent;
end

% Recurse on groups to render all widgets
% Must traverse children in placement-order
for i = 1: length(childObjOrder)
    hChild = childObjOrder{i};
    render(hChild, childGraphicalParent);
end

% Perform any post-render tasks,
% such as SelectionConstraint listeners.
% This method is called only for uigroups:
%
h.renderPost;

% For flush at end of group redraw
drawnow expose;

% [EOF]
