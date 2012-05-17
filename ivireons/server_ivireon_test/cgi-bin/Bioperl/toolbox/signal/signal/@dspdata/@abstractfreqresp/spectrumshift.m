function [H,W] = spectrumshift(this,H,W)
%SPECTRUMSHIFT   Shift zero-frequency component to center of spectrum.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:00:37 $

if nargin == 1,
    H = this.Data;
    W = this.Frequencies;
end

% Convert to plot + and - frequencies.
H = fftshift(H);  % Places the Nyquist freq on the negative side.

[nfft,nchans] = size(H);

% Determine half the number of FFT points.
if rem(nfft,2),
    halfNfft = (nfft+1)/2;  % ODD
    negEndPt = halfNfft;

else
    halfNfft = (nfft/2)+1;  % EVEN
    negEndPt = halfNfft-1;
    
    % Move the Nyquist point to the right-hand side (pos freq) to be
    % consistent with plot when looking at the positive half only.
    H = [H(2:end,:); H(1,:)];
end

W = [-flipud(W(2:negEndPt)); W(1:halfNfft)]; % -Nyquist:Nyquist

if nargout == 0,
    this.Data = H;
    this.Frequencies = W;
end

% [EOF]
