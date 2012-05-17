function child = addchild(h, blk)
%ADDCHILD

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:03 $

child = fxptui.createsubsys(blk);
child.userdata.displayicon = '';
jchild = java(child);
jchild.acquireReference;
h.hchildren.put(child.daobject, jchild);

% [EOF]
