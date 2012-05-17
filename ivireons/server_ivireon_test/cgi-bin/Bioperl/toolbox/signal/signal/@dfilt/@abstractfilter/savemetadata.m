function s = savemetadata(this)
%SAVEMETADATA   Save the metadata.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:17:25 $

s.fdesign      = getfdesign(this);
s.fmethod      = getfmethod(this);
s.measurements = get(this, 'privMeasurements');

% [EOF]
