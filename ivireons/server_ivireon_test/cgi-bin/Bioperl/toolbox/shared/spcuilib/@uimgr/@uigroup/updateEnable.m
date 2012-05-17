function updateEnable(h,ena)
%updateEnable Update enable state of widget and all children.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:53 $

% See updateVisible() for comments on this implementation.

if isempty(h.WidgetFcn)
    % Update .Enable property of each child in group
    hChild = h.down; % get first child
    while ~isempty(hChild)
        hChild.Enable = ena;
        hChild = hChild.right; % get next child
    end
else
    % Just update group widget, if rendered
    setWidgetProp(h,'Enable',ena);
end

% [EOF]
