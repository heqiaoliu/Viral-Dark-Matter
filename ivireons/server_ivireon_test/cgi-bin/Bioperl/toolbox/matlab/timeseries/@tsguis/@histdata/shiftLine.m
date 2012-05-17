function shiftLine(h,ind,delta)

% Copyright 2006 The MathWorks, Inc.

% Vertical shift of selected line

h.YData(:,ind) = h.YData(:,ind)+delta;