function multiratedefaults(this, maxfactor)
%MULTIRATEDEFAULTS   Setup the defaults for multirate.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:24:12 $

fs = 1 -  1/maxfactor;
fp = 1 - .8/maxfactor;

if ~this.NormalizedFrequency
    fp = fp*this.Fs/2;
    fs = fs*this.Fs/2;
end

set(this, 'Fstop', fs, 'Fpass', fp);

% [EOF]
