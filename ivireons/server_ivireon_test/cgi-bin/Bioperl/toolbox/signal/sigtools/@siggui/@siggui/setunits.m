function setunits(hObj,units)
%SETUNITS Sets all units in the frame

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2007/12/14 15:19:50 $

error(nargchk(2,2,nargin,'struct'));

siggui_setunits(hObj, units);

% [EOF]
