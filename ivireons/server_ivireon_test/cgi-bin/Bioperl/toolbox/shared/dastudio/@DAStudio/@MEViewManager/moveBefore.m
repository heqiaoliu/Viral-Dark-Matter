function moveBefore(h, viewToMove, viewBefore)
% Rearranges the given views

%   Copyright 2009 The MathWorks, Inc.

v1 = h.getView(viewToMove);
% disconnect it from the hierarchy.
v1.disconnect;

v2 = h.getView(viewBefore);
v1.connect(v2, 'right');