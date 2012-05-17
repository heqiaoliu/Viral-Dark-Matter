function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:35:13 $

tw = get(this, 'TransitionWidth');

if this.NormalizedFrequency, Fs = 2;
else,                        Fs = this.Fs; end

band = get(this, 'Band');

minfo.Fpass = Fs/2/band-tw/2;
minfo.Fstop = Fs/2/band+tw/2;
minfo.Apass = [];
minfo.Astop = this.Astop;

% [EOF]
