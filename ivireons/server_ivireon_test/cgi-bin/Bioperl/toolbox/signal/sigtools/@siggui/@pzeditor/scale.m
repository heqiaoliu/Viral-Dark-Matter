function scale(hObj, factor)
%SCALE Scale by a factor
%   SCALE(hPZ, FACTOR) Scale the current Pole/Zero by FACTOR

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/12/14 15:19:11 $

error(nargchk(2,2,nargin,'struct'));

hPZ = get(hObj, 'CurrentRoots');

setvalue(hPZ, double(hPZ)*factor);

% [EOF]
