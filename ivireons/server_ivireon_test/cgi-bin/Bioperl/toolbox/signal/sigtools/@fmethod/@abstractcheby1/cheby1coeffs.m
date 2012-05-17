function [num,a1,w0] = cheby1coeffs(h,N,wp,rp)
%CHEBY1COEFFS   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:19:11 $


[cs,theta] = costheta(h,N);

ss = sin(theta);

a = 1/N*asinh(1/sqrt(10^(rp/10)-1));

w0 = wp*sinh(a);

wi = wp*ss;

num = w0^2+wi.^2;

c = 2*w0;
a1 = -c*cs;

% [EOF]
