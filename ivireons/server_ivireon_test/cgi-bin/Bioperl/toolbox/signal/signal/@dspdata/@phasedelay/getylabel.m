function ylbl = getylabel(this)
%GETYLABEL   Get the ylabel.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:28 $

if this.NormalizedFrequency
    ylbl = 'Phase delay (samples)';
else
    ylbl = 'Phase delay (radians/Hz)';
end

% [EOF]
