function Ha = design(h,hs)
%DESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:51:42 $

N = hs.FilterOrder;
wp = hs.Wpass;
rp = hs.Apass;
[s,g] = sosacheby1lp(h,N,wp,rp);
Ha = afilt.sos(s,g);
%------------------------------------------------------------------
function [s,g] = sosacheby1lp(h,N,wp,rp)
%SOSACHEBY1LP Lowpass analog Chebyshev type I filter second-order sections.

% Initialize sos matrix
ms = ceil(N/2);
msf = floor(N/2);
s = zeros(ms,6);

% Set first denominator coefficient
s(1:msf,4) = ones(msf,1);

% Compute transfer function coefficients
[num,a1,w0] = cheby1coeffs(h,N,wp,rp);

% Set all numerators
s(1:msf,3) = num;

% Set 4rd denom coeff
s(1:msf,6) = s(1:msf,3);

% Set 2nd denom coeff
s(1:msf,5) = a1;

if rem(N,2),
    s(end,3) = w0;
    s(end,5:6) = [1, w0];
    g = 1;
else
    g = sqrt(10^(-rp/10));
end

% [EOF]
