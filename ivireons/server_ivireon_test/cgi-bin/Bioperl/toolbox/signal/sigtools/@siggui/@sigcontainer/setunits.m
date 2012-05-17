function setunits(hObj, units)
%SETUNITS Set the units of the frame and its children

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2007/12/14 15:19:34 $

error(nargchk(2,2,nargin,'struct'));

% Set the units for the object itself
siggui_setunits(hObj, units);

% Set the units of the objects children
for hindx = allchild(hObj)
    if isrendered(hindx), setunits(hindx, units); end
end

% [EOF]

