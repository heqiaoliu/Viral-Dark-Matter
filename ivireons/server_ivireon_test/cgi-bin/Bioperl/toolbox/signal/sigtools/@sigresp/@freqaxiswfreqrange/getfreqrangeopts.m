function rangeopts = getfreqrangeopts(this, opts)
%GETFREQRANGEOPTS   Return the frequency range options.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:29:06 $

if nargin < 2,
    normalizedstatus = this.NormalizedFrequency;
else
    normalizedstatus = opts.normalizedstatus;
end

% Note that the starting point for the -pi-pi range is hardcoded to be
% inclusive, however this should depend on NFFT. NFFT is only available in
% subclasses, freqaxiswnfft.
if strcmpi(normalizedstatus, 'on'),
   rangeopts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
else
   rangeopts = {'[0, Fs/2)', '[0, Fs)', '[-Fs/2, Fs/2)'};
end

% [EOF]
