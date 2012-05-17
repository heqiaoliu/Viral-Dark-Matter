function fracdelay = getfracdelay(this)
%GETFRACDELAY   Get the fracdelay.

%   Author(s): V. Pellissier
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:36:30 $

fracdelay = this.privFracDelay;
if fracdelay<0,
    error(generatemsgid('InvalidFracDelay'), ...
        'The fractional delay must be positive.');
end

if this.NormalizedFrequency,
    Fs = 1;
else
    Fs = this.Fs;
end
if fracdelay>=1/Fs,
    error(generatemsgid('InvalidFracDelay'), ...
        ['The fractional delay must be strictly lower than ',num2str(1/Fs),'.']);
end

% [EOF]
