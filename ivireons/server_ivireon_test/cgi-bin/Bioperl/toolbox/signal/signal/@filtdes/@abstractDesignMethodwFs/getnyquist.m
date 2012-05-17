function fn = getnyquist(d)
%GETNYQUIST Returns the nyquist frequency.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/01 20:07:37 $

if strncmpi(get(d, 'freqUnits'), 'normalized', 10),
    fn = 1;
else
    fn = get(d, 'Fs')/2;
end

% [EOF]
