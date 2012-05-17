function rangeopts = freqaxiswnfft_getfreqrangeopts(this, opts)
%FREQAXISWNFFT_GETFREQRANGEOPTS    Get the frequency range based on the
%input values.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:29:24 $

if nargin < 2,
    normalizedstatus = this.NormalizedFrequency;
    nfft = lclgetnfft(this);
else
    if isfield(opts,'normalizedstatus'),
        normalizedstatus = opts.normalizedstatus;
    else
        normalizedstatus = this.NormalizedFrequency;
    end
    if isfield(opts,'nfft'),
        nfft = opts.nfft;
    else
        nfft = lclgetnfft(this);
    end
end

minPt = '[';  % Even case, include nyquist point.
if rem(nfft,2),  
    minPt = '(';  % Odd case, don't include nyquist point.
end

if strcmpi(normalizedstatus, 'on'),
   rangeopts = {'[0, pi)', '[0, 2pi)', sprintf('%c-pi, pi)', minPt)};
else
   rangeopts = {'[0, Fs/2)', '[0, Fs)', sprintf('%c-Fs/2, Fs/2)', minPt)};
end

%--------------------------------------------------------------------------
function nfft = lclgetnfft(this)

if isempty(getparameter(this,getnffttag(this))),
    nfft = 512;
else
    nfft = this.NumberofPoints;
end

% [EOF]