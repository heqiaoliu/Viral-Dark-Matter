function visitChildrenLeafOnly(h,fcn)
%visitChildrenLeafOnly Apply function to leaf child nodes only.
%   Visit leaf child nodes and apply function to each, starting from the
%   "left."

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:47 $

while ~isempty(h)
    if isempty(h.down)
        fcn(h); % apply fcn to leaf node
    else
        iterator.visitChildrenLeafOnly(h.down,fcn); % descend
    end
    h = h.right;  % go to right sibling
end

% [EOF]
