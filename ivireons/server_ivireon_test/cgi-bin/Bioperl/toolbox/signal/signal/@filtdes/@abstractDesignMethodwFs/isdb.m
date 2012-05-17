function boolflag = isdb(d)
%ISDB Returns true if the magUnits are in dB.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/01 20:07:38 $

boolflag = false;
if isprop(d, 'magUnits') && strcmpi(get(d, 'magUnits'), 'db'),
    boolflag = true;
end

% [EOF]
