function Ha = design(h,hs)
%DESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:50:00 $

N = hs.FilterOrder;
wc = hs.Wcutoff;

[s,g] = sosabutterlp(h,N,wc);
Ha = afilt.sos(s,g);
%------------------------------------------------------------------
function [s,g] = sosabutterlp(h,N,wc)
%SOSABUTTLP Lowpass analog Butterworth filter second-order sections.

% Initialize sos matrix
ms = ceil(N/2);
msf = floor(N/2);
s = zeros(ms,6);

% Set all numerators
s(:,3) = ones(ms,1);

% Set third denominator coefficient
s(:,6) = ones(ms,1);

% Set first denominator coefficient
s(1:msf,4) = 1/(wc^2)*ones(msf,1);

% Compute cosine of angles of stable butterworth poles
cs = costheta(h,N);

% Set 2nd denom coeff
cw = 1/wc;
c = 2*cw;
s(1:msf,5) = -c*cs;

if rem(N,2),
    s(end,5) = cw;
end

g = 1;

% [EOF]
