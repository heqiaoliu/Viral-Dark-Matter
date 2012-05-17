function y = compatibleParent(this,parentClass) %#ok
%compatibleParent Check for compatibility with proposed parent object.
%   Returns FALSE if this object does not allow itself to be a child
%   under the indicated parent object.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2006/06/27 23:32:01 $

y = strcmpi(parentClass,{'uimgr.uifigure','uimgr.uigroup'});

% [EOF]
