function place = getDefaultPlacement(hGroup)
%getDefaultPlacement Return default placement for new child of uigroup.
%  Returns default value to use for a new child of a uigroup, when
%  no placement has been specified.
%
%  Rules:
%   - Low values of placement imply first items to place
%     This is so that placement runs in the positive direction
%     and the first item has placement 0 (by default), the next
%     placement 1, and so on.
%   - If there are no existing children in group,
%     placement value of new child will be 0
%   - If there are existing children in group,
%     placement value of new child will be (maxPlace + 1),
%     where maxPlace is the maximum placement found across
%     all existing children in group.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:30:59 $

hChild = hGroup.down; % get first child
if isempty(hChild)
    % No children in group
    % First entry in a group gets placement 0,
    % if no expicit value was set by caller
    place = 0;
else
    maxPlace = -inf;  % lowest possible placement value
    while ~isempty(hChild)
        t = hChild.ActualPlacement;
        if (maxPlace<t), maxPlace=t; end
        hChild = hChild.right; % get next child
    end
    place = maxPlace+1;
end

% [EOF]
