function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:31:20 $

astop = get(this, 'Astop');
apass = convertmagunits(convertmagunits(astop, 'db', 'linear', 'stop'), 'linear', 'db', 'pass');

minfo.Fpass = [];
minfo.Fstop = [];
minfo.Apass = apass;
minfo.Astop = astop;

% [EOF]
