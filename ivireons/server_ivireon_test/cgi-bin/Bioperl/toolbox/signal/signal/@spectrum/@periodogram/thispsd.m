function [Pxx,W] = thispsd(this,x,opts)
%THISPSD Calculate the power spectral density (PSD) via periodogram.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $Date: 2007/12/14 15:14:45 $

error(nargchk(2,3,nargin,'struct'));

% Generate window.
this.Window.length = length(x);
win = generate(this.Window);

[Pxx W] = periodogram(x,...
    win,...
    opts{:});  % NFFT, Fs(?), and SpectrumType

% [EOF]
