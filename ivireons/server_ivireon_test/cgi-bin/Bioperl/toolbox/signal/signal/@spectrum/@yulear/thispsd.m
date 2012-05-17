function [Pxx,W] = thispsd(this,x,opts)
%THISPSD Calculate the power spectral density (PSD) via PYULEAR.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $Date: 2007/12/14 15:14:49 $

error(nargchk(2,3,nargin,'struct'));

[Pxx W] = pyulear(x,...
    this.Order,...
    opts{:});  % NFFT, Fs(?), and SpectrumType

% [EOF]
