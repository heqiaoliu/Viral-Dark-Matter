function rangeopts = getfreqrangeopts(this, normalizedStatus, nfft)
%GETFREQRANGEOPTS    Frequency range options based on the frequency units.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:29:32 $

if nargin < 3,
    if isempty(this.Spectrum),
        nfft = 0;
    else
        nfft = length(this.Spectrum.Data);
    end
    if nargin < 2,
        normalizedStatus = this.NormalizedFrequency;
    end
end

endPt = ']';      % Even case, include nyquist point. Use this by default.
if rem(nfft,2),  
    endPt = ')';  % Odd case, don't include nyquist point.
end

if strcmpi(normalizedStatus, 'on'),
    rangeopts = {sprintf('[0, pi%c',endPt), '[0, 2pi)', sprintf('(-pi, pi%c',endPt)};
else
    rangeopts = {sprintf('[0, Fs/2%c',endPt), '[0, Fs)', sprintf('(-Fs/2, Fs/2%c',endPt)};
end

% [EOF]
