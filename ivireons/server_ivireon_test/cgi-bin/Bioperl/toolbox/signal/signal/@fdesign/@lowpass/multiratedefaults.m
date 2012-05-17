function multiratedefaults(this, maxfactor)
%MULTIRATEDEFAULTS   Setup the lowpass object for multirate.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:25:02 $

% Put Fstop at the band point so that there is no aliasing back into the
% transition width.
fs =  1/maxfactor;
fp = .8/maxfactor;

% Scale by the sampling frequency.
if ~this.NormalizedFrequency
    fp = fp*this.Fs/2;
    fs = fs*this.Fs/2;
end

set(this, 'Fpass', fp, 'Fstop', fs);

% [EOF]
