function c = fvw(hObj)
%FVW Get the first character for the freqspecs

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 22:53:38 $

% This should be a protected method

if strncmpi(hObj.freqUnits, 'normalized', 10),
    c = 'w';
else
    c = 'F';
end

% [EOF]
