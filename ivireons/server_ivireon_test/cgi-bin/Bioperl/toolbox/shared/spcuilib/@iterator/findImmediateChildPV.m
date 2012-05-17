function hChild = findImmediateChildPV(h,param,value)
%findImmediateChildPV Return first-level child with given parameter value.
%   Return first-level child node that has parameter with matching value.
%   If no matching child is found, returns with empty handle.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:21:37 $

% Alt: (includes parent in the match process!)
hChild = find(h,'-depth',1,param,value);

% When code falls through, either:
%  - no match was found,
%    in which case we return with hChild set to empty
%  - match was found,
%    in which case the desired hChild is returned

% [EOF]
