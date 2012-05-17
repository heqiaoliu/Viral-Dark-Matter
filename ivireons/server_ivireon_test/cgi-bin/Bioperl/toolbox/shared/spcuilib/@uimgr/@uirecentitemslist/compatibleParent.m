function y = compatibleParent(this,parentClass)
%compatibleParent Check for compatibility with proposed parent object.
%   Returns FALSE if this object does not allow itself to be a child
%   under the indicated parent object.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:38 $

y = strcmpi(parentClass,'uimgr.uimenugroup');

% [EOF]
