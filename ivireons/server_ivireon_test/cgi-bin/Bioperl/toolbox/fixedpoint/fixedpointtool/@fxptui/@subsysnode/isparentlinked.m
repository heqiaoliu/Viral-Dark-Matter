function b = isparentlinked(h)
%ISPARENTLINKED True if the parent of the daobject for this node is linked

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:34:09 $

try
  parent = h.daobject.getParent;
catch
  parent = [];
end
b = ~isempty(parent) && parent.isLinked;

% [EOF]
