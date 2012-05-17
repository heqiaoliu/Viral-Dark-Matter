function [hopts,opts] = saopts(this,segLen,hopts)
%SAOPTS   Return options for the spectral analysis commdand-line functions.
%
%   Sets up the options in the correct order to be passed in to the command
%   line functions pwelch, pmusic, etc.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:37:04 $

opts = {hopts.SpectrumType};
if ~hopts.NormalizedFrequency,
    opts = {hopts.Fs, opts{:}};  % Prepend Fs.
end

% If Welch use the segment length, instead of the input length.
if useseglenfornfft(this),
    segLen = this.SegmentLength;
end
% Determine numeric value of NFFT if it's set to a string.
nfft = calcnfft(hopts,segLen);

opts = {nfft,opts{:}};     % Prepend NFFT.

% [EOF]
