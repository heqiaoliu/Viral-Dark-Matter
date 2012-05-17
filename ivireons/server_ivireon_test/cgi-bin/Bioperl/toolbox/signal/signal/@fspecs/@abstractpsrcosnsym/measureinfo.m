function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:05 $

minfo.Fpass = (1-this.RolloffFactor)/this.SamplesPerSymbol;
minfo.Fstop = (1+this.RolloffFactor)/this.SamplesPerSymbol;
minfo.Apass = [];
minfo.Astop = [];

% [EOF]
