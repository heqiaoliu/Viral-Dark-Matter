function boo = isVisible(h)
%ISVISIBLE  True if Property Editor is visible.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:12:53 $
boo = h.Java.Frame.isVisible;