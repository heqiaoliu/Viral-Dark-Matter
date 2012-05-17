function remove(h)
%REMOVE Destroy widget if rendered.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:10 $

% Unrender this widget, and all children widgets
h.unrender_widget;  % slightly more efficient than h.unrender

% Remove this node from hierarchy, leaving intact all
% children connected to this (now dangling) node
h.disconnect;

% [EOF]
