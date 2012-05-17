function y = areAnyChildren(h)
%areAnyChildren True if any children exist in uigroup.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:36 $

% If there are any children, .down will be non-empty
y = ~isempty(h.down);

% [EOF]
