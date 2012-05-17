function [Pxx,W] = thispsd(this,x,opts)
%THISPSD Calculate the power spectral density (PSD) via Burg.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $Date: 2007/12/14 15:14:25 $

error(nargchk(2,3,nargin,'struct'));

[Pxx W] = pburg(x,...
    this.Order,...
    opts{:});  % NFFT, Fs(?), and SpectrumType

% [EOF]
