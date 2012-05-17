function Fs = getfs(h,Fs)
%GETFS   Pre-Get Function for the Fs property.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:11:06 $

if h.NormalizedFrequency,
    Fs = 'Normalized';
else
    Fs = h.privFs;
end

% [EOF]
