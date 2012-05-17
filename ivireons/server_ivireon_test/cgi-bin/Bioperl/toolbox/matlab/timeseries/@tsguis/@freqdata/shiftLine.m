function shiftLine(h,ind,delta)

% Copyright 2006 The MathWorks, Inc.

% Vertical shift of selected line

h.Response(:,ind) = h.Response(:,ind)+delta;