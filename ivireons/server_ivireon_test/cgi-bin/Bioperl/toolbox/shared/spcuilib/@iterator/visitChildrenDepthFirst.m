function visitChildrenDepthFirst(h,fcn)
%visitChildrenDepthFirst Apply function to children in depth-first order.
%   Visit all child nodes and apply function to each, in depth-first order
%   starting from the "left."

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:46 $

% Depth-first, no LHS arg
while ~isempty(h)
    iterator.visitChildrenDepthFirst(h.down,fcn); % descend
    fcn(h);       % apply fcn
    h = h.right;  % go to right sibling
end

% [EOF]
