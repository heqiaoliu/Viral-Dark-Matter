function hax = getbottomaxes(hObj)
%GETBOTTOMAXES Returns the axes on the bottom

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:24 $

h = get(hObj, 'Handles');

if length(h.axes) == 1,
    hax = h.axes;
else
    order = gethgstackorder(h.axes);
    hax = h.axes(find(order == min(order)));
end

% [EOF]
