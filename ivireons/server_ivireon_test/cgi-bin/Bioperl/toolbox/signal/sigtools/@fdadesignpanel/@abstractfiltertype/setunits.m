function setunits(h, units)
%SETUNITS NO OP for abstractfiltertype's

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 22:53:29 $

G = findhandle(h,whichframes(h));
for i = 1:length(G),
    setunits(G(i),units);
end

% [EOF]
