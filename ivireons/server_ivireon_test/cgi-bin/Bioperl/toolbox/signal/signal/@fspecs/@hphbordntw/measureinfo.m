function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:49:04 $

tw = get(this, 'TransitionWidth');

if this.NormalizedFrequency, fs = 2;
else,                        fs = this.Fs; end

minfo.Fpass = fs/4+tw/2;
minfo.Fstop = fs/4-tw/2;

minfo.Apass = [];
minfo.Astop = [];


% [EOF]
