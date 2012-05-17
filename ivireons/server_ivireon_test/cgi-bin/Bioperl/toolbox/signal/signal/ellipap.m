function [z,p,k] = ellipap(n, rp, rs)
%ELLIPAP Elliptic analog lowpass filter prototype.
%   [Z,P,K] = ELLIPAP(N,Rp,Rs) returns the zeros, poles, and gain
%   of an N-th order normalized prototype elliptic analog lowpass
%   filter with Rp decibels of ripple in the passband and a
%   stopband Rs decibels down.

%   Author(s): S. Orfanidis
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.7 $  $Date: 2009/12/28 04:35:12 $

%   References:
%     [1] T. W. Parks and C. S. Burrus, Digital Filter Design,
%         John Wiley & Sons, 1987, chapter 7, section 7.3.7-8.

error(nargchk(3,3,nargin,'struct'));

validateattributes(n,{'numeric'},{'scalar','integer','positive'},'ellipap','N');
validateattributes(rp,{'numeric'},{'scalar','nonnegative'},'ellipap','Rp');
validateattributes(rs,{'numeric'},{'scalar','nonnegative'},'ellipap','Rs');

if rp == 0,
    error(generatemsgid('zeroApass'),...
        'Passband ripple cannot be zero. Use CHEBY2 or BUTTER if no passband ripple is desired.');
end

if rp >= rs,
    error(generatemsgid('ApassGTAstop'),...
        'Stopband attenuation must be greater than passband ripple.');
end

[z,p,H0] = ellipap2(n,rp,rs);

k = abs(H0*prod(p)/prod(z));

