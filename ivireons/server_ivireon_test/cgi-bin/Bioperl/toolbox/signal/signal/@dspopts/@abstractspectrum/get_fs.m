function Fs = get_fs(h, Fs) %#ok
%GETFS   Pre-Get Function for the Fs property.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:20:36 $

if h.NormalizedFrequency,
    Fs = 'Normalized';
else
    Fs = h.privFs;
end

% [EOF]
