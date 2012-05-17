function y = hasChildGroups(h)
% Return true if this group has any children that are groups.
% No descent; checks immediate children only.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:01 $

y = false;
h = h.down; % get first child, if any
while ~isempty(h)
    if h.isGroup
        y = true; return
    end
    h = h.right; % get next child
end

end % hasChildGroups

% [EOF]
