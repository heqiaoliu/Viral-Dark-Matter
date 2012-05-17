function N = getNumChildren(h)
%getNumChildren Return number of children in uigroup.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:42 $

N=0;
h=h.down; % go to children
while ~isempty(h)
    N=N+1;       % child exists - count it
    h=h.right; % next child
end

% [EOF]
