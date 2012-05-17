function h = jakesir(fd, t);
%JAKESIR  Jakes Doppler filter impulse response.
%   H = JAKESIR(FD, T) returns the impulse response of a Jakes Doppler
%   filter.  FD is the maximum Doppler shift (in Hz).  T is a vector of
%   time-domain values.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:22:50 $

% First compute normalized function x^-1/4 J_1/4(x), and its peak value.
nu=1/4;  % nu-parameter for fractional Bessel function.
absx = abs(2*pi*fd*t);
JFcnPeak = (1/2)^nu / gamma(nu+1);
JFcn = real(absx.^-nu .* besselj(nu, absx));
JFcn(isnan(JFcn)) = JFcnPeak;  % Set peak value correctly.

% Normalized impulse response of Jakes filter.
LJ = length(JFcn);
windowFcn = hamming(LJ).';
hjw = JFcn .* windowFcn;
h = hjw./sqrt(sum(abs(hjw).^2));
