function [Pxx,W] = thispsd(this,x,opts)
%THISPSD Calculate the power spectral density via Welch's method.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $Date: 2007/12/14 15:14:47 $

error(nargchk(2,3,nargin,'struct'));

% Generate window vector.
this.Window.length = this.SegmentLength;  % Window is a private property
win = generate(this.Window);

NOverlap = overlapsamples(this);

% Calculate PSD.
[Pxx W] = pwelch(x,...
    win,...
    NOverlap,...
    opts{:}); % NFFT, Fs(?), and SpectrumType

% [EOF]
