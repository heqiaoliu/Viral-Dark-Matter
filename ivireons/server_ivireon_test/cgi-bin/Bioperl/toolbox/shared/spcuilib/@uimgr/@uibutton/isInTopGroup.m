function y = isInTopGroup(hChild)
%isInTopGroup True if item is first rendered child.
%   Assumes hChild is the first (lowest placement) child.
%   Assumes hChild is a uimgr.uibutton

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/10/08 18:12:15 $

% Check that this is the FIRST child of the parent,
% (not just that it's the lowest-placement child in its group)

y = false;
hParent = hChild.up;  % get parent
while 1
    if isa(hParent,'uimgr.uitoolbar')
        y = true;
        return
    end
    if ~isa(hParent,'uimgr.uibuttongroup') || ~hParent.isFirstPlace
        return
    end
    hParent = hParent.up;  % get parent
end

% [EOF]
