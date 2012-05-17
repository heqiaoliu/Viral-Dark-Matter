function h = flatir(fd, t)
%FLATIR  Flat Doppler filter impulse response.
%   H = FLATIR(FD, T) returns the impulse response of a flat Doppler
%   filter.  FD is the maximum Doppler shift (in Hz).  T is a vector of
%   time-domain values.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:36:15 $


FFcn = real(sqrt(1.0/(2*fd)) * 2*fd * sinc(2*fd*t));

% Normalized impulse response of flat filter.
LF = length(FFcn);
windowFcn = hamming(LF).';
hfw = FFcn .* windowFcn;
h = hfw./sqrt(sum(abs(hfw).^2));
