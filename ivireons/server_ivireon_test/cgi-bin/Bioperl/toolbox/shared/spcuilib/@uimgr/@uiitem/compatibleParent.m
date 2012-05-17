function y = compatibleParent(this,parentClass) %#ok
%compatibleParent Check for compatibility with proposed parent object.
%   Returns FALSE if this object does not allow itself to be a child
%   under the indicated parent object.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/02/02 13:12:17 $

% Default: this child is compatible with all possible parent objects
% Generally, this method is overloaded in all subclasses.

y = true;

% [EOF]
