function y = isempty(h)
%ISEMPTY True if installer has no plan to install.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:41:01 $

y = isempty(h.Plan);

% [EOF]
