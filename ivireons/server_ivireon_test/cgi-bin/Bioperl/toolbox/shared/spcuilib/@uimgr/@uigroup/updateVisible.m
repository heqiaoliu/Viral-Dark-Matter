function updateVisible(h,vis)
%updateVisible Update visibility of all children of uigroup.
%  This overload is present purely for efficiency.
%  Without this, the uiitem method produces correct but slow results.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:34:13 $

% Set visibility of uigroup's own widget
%
% Visibility state is passed in, since this function is called
% by a schema set-function (i.e., the value is not yet
% set in the object).  Thus, we cannot simply do this:
%   vis = h.Visible;
% since .Visible is not yet set in object.

% There is an optimization required when the group has a widget,
% AND it has children.  In these situations, changing the visibility
% of the group widget automatically changes the visibility of the
% children widgets in all known cases.  Thus, we don't need to
% touch the children explicitly for their visibility to be updated.
% Note that the UIMgr nodes won't know this, however, so that
% examining their .Visible property won't reflect the updates
% visibility of the child widgets themselves.  But this is desired;
% the spec is that visibility of children is maintained, even when
% parent changes visibility.

% Optimized to only change visibility of group widget, if it
% has a WidgetFcn.  Otherwise, we explicitly visit the children
%
if isempty(h.WidgetFcn)
    % Update .Visible property of each child in group
    hChild = h.down; % get first child
    while ~isempty(hChild)
        hChild.Visible = vis;
        hChild = hChild.right; % get next child
    end
else
    % Just update group widget, if rendered
    hWidget = h.hWidget;
    if ~isempty(hWidget)
        set(hWidget,'Visible',vis);
    end
end

% [EOF]
