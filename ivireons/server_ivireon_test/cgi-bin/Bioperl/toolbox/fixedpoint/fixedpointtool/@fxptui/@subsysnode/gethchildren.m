function children = gethchildren(h)
%GETHCHILDREN gets the wrappable subsystems beneath this node

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:15 $

children = h.daobject.getHierarchicalChildren;
children = fxptui.filter(children);
% [EOF]
