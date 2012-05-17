function h = gaussianir(fc, t)
%GAUSSIANIR  Gaussian Doppler filter impulse response.
%   H = GAUSSIANIR(FC, T) returns the impulse response of a gaussian
%   Doppler filter.  FC is the 3-dB cutoff frequency (in Hz).  T is a
%   vector of time-domain values.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:36:16 $


GFcn = real( pi^(1/4)*sqrt(2)*sqrt(fc)/(log(2))^(1/4) ...
        * exp(-2*pi^2/log(2)*fc^2*t.^2) );

% Normalized impulse response of gaussian filter.
LG = length(GFcn);
windowFcn = hamming(LG).';
hgw = GFcn .* windowFcn;
h = hgw./sqrt(sum(abs(hgw).^2));
