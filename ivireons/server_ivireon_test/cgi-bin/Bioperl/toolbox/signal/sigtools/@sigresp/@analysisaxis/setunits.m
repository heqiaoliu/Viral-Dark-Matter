function setunits(this, units)
%SETUNITS   Set the units of the contained objects.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:40 $

set(this.Handles.axes, 'Units', units);

% [EOF]
