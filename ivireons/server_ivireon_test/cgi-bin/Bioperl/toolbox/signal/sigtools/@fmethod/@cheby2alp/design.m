function Ha = design(h,hs)
%DESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:53:09 $

N = hs.FilterOrder;
ws = hs.Wstop;
rs = hs.Astop;
[s,g] = sosacheby2lp(h,N,ws,rs);
Ha = afilt.sos(s,g);
%------------------------------------------------------------------
function [s,g] = sosacheby2lp(h,N,ws,rs)
%SOSACHEBY2LP Lowpass analog Chebyshev type II filter second-order
%sections.

% Initialize sos matrix
ms = ceil(N/2);
msf = floor(N/2);
s = zeros(ms,6);

% Set last denominator coefficient
s(1:msf,6) = ones(msf,1);

% Compute transfer function coefficients
[b0,a1,a0,w0] = cheby2coeffs(h,N,ws,rs);

% Set last numerator coefficient
s(1:msf,3) = 1;

% Set 1st num coeff
s(1:msf,1) = b0;

% Set 1st den coeff
s(1:msf,4) = a0;

% Set 2nd denom coeff
s(1:msf,5) = a1;

if rem(N,2),
    s(end,3) = w0;
    s(end,5:6) = [1, w0];
end
g = 1;


% [EOF]
