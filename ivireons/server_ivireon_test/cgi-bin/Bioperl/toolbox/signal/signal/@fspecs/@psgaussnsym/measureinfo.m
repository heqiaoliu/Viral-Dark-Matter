function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:03:01 $

minfo.Fpass = 2*this.BT/this.SamplesPerSymbol;
% Note that:
% Fpass is in normalized frequency
% Fpass = B/(Fs/2);  Fs is the sampling frequency
% Fpass = B/(Fs/2) * T/(sps/Fs);
% Fpass = 2*B*T/sps;
minfo.Fstop = [];
minfo.Apass = [];
minfo.Astop = [];

% [EOF]
