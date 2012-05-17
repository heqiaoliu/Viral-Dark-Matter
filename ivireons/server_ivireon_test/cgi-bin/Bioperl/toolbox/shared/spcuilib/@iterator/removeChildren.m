function removeChildren(h)
%removeChildren Remove all child nodes.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:21:40 $

% Disconnect children in reverse order,
% to minimize memory/link thrashing
%
hlast=h.down('last'); % last child
while ~isempty(hlast)
    hprev=hlast.left;
    disconnect(hlast);
    hlast=hprev;
end

% [EOF]
