function s = savemetadata(this)
%SAVEMETADATA   Save any meta data.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:33:44 $

s.fdesign      = getfdesign(this);
s.fmethod      = getfmethod(this);
s.measurements = get(this, 'privMeasurements');
s.designmethod = get(this, 'privdesignmethod');

% [EOF]
