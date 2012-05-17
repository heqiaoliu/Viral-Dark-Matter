function y = isInTopGroup(hChild)
%isInTopGroup True if item is first rendered child.
%   Assumes hChild is the first (lowest placement value) child.
%   Assumes hChild is a uimgr.uibutton

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:34 $

% Check that this is the FIRST child of the parent,
% (not just that it's the lowest placement-value child in its group)

% The parent cannot be a uimenu, since uimenu's do not support children.
% Hence, no need to check if parent is a uimenugroup --- of course it is!
% We only need to check if parent has a WidgetFcn.  If it does, then
% we're in a new panel.

y = false;
hParent = hChild.up;  % get parent
while isa(hParent,'uimgr.uimenugroup')
    if ~isempty(hParent.WidgetFcn)
        y = true;
        return
    end
    if ~hParent.isFirstPlace
        return
    end
    hParent = hParent.up;  % get parent
end

% [EOF]
