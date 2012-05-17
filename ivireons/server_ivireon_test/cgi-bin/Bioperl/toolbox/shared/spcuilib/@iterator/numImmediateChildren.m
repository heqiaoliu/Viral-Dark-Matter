function N = numImmediateChildren(h)
%numImmediateChildren Count first-level children of parent object.
%
% Assumes children are "down" from parent object,
% connect via "connect" method.
  
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:21:38 $

N=0;
hc=h.down; % first child (if any)
while ~isempty(hc)
    N=N+1;
    hc=hc.right;  % next child
end

% [EOF]
