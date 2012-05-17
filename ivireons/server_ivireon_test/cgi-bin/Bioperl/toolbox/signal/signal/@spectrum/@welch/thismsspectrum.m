function [Sxx,W] = thismsspectrum(this,x,opts)
%THISMSSPECTRUM   Mean-square Spectrum via Welch's method.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $Date: 2007/12/14 15:14:46 $

error(nargchk(2,3,nargin,'struct'));

% Generate Window vector.
this.Window.length = this.SegmentLength;  % Window is a private property
win = generate(this.Window);

NOverlap = overlapsamples(this);

[Sxx W] = pwelch(x,...
    win,...
    NOverlap,...
    opts{:},...     % NFFT, Fs(?), and SpectrumType
    'ms');          % Window compensation produces correct peak heights.

% [EOF]
