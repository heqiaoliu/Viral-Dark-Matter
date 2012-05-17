function [Sxx,W] = thismsspectrum(this,x,opts)
%THISMSSPECTRUM   Mean-square Spectrum via periodogram.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $Date: 2007/12/14 15:14:44 $

error(nargchk(2,3,nargin,'struct'));

% Generate window vector.
this.Window.length = length(x);
win = generate(this.Window);

[Sxx W] = periodogram(x,...
    win,...
    opts{:},...     % NFFT, Fs(?), and SpectrumType
    'ms');          % Compensate for window so that it produces correct peak heights.

% [EOF]
