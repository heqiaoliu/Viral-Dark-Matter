function enableChildren(h,ena)
%enableChildren Enable children of a group, not the group widget itself.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/05/09 23:40:03 $

% We don't need to follow placement-order in carrying this out
% (Makes it a bit more efficient to skip the sort)
hChild=h.down;
while ~isempty(hChild)
    hChild.Enable=ena;
    hChild=hChild.right;
end

% [EOF]
