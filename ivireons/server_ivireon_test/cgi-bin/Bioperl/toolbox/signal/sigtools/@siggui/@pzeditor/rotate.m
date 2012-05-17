function rotate(hObj, R)
%ROTATE Rotate Pole/Zero
%   ROTATE(hOBJ, R) Rotate the current Pole/Zero by R radians

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:32 $

hPZ = get(hObj, 'CurrentRoots');

setvalue(hPZ, double(hPZ) * (sin(R)*i + cos(R)))

updatelimits(hObj);

% [EOF]
