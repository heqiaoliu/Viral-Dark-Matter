function [z,p,k] = cheb1ap(n, rp)
%CHEB1AP Chebyshev Type I analog lowpass filter prototype.
%   [Z,P,K] = CHEB1AP(N,Rp) returns the zeros, poles, and gain
%   of an N-th order normalized analog prototype Chebyshev Type I
%   lowpass filter with Rp decibels of ripple in the passband.
%   Chebyshev Type I filters are maximally flat in the stopband.
%
%   See also CHEBY1, CHEB1ORD, BUTTAP, CHEB2AP, ELLIPAP.

%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2009/07/14 04:00:04 $

validateattributes(n,{'numeric'},{'scalar','integer','positive'},'cheb1ap','N');
validateattributes(rp,{'numeric'},{'scalar','nonnegative'},'cheb1ap','Rp');

epsilon = sqrt(10^(.1*rp)-1);
mu = asinh(1/epsilon)/n;
p = exp(1i*(pi*(1:2:2*n-1)/(2*n) + pi/2)).';
realp = real(p); realp = (realp + flipud(realp))./2;
imagp = imag(p); imagp = (imagp - flipud(imagp))./2;
p = complex(sinh(mu).*realp , cosh(mu).*imagp);
z = [];
k = real(prod(-p));
if ~rem(n,2)	% n is even so patch k
	k = k/sqrt((1 + epsilon^2));
end
