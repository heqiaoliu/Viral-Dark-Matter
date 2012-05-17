function [s,g] = bilineardesign(h,has,c)
%BILINEARDESIGN  Design digital filter from analog specs. using bilinear. 

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:53:15 $

N = has.FilterOrder;
if rem(N,2) == 1,
    error(generatemsgid('oddOrder'),...
        'Filter order must be an even integer.');
end
if rem(N,4) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('twiceEvenOrder'),...
        'Half of the filter order must be an odd integer for the filter structure specified.');
end

ws = has.Wstop;
rs = has.Astop;

% Compute Chebyshev II coeffs
[b0,a1,a0,w0,c0] = cheby2coeffs(h,N/2,ws,rs);

% Compute den coeffs
den = 1+a1+a0;
ai1 = 4*c*(c0-a0)./den;
ai2 = 2*(a0*(2*c^2+1)-1)./den;
ai3 = -4*c*(c0+a0)./den;
ai4 = (1-a1+a0)./den;

fog = (1+b0)./den; %Fourth-order gains

% Initialize matrix
[s,g] = sosinitbpbs(h,N,ai1,ai2,ai3,ai4,fog);

% Compute num coeffs
nden = 1+b0;
bi1 = -4*c*b0./nden;
bi2 = 2*(b0*(2*c^2+1)-1)./nden;

% Form SOS numerators
msf = 2*floor(N/4);
for k = 1:2:msf-1,
    r = roots([1 -bi1(ceil(k/2)) bi2(ceil(k/2))-2]);
    s(k,1:3) = [1 r(1) 1];
    s(k+1,1:3) = [1 (bi2(ceil(k/2))-2)/r(1) 1];
end

if rem(N,4),
    s(end,1:3) = [1 0 -1];
    s(end,4:6) = [1 -2*c/(w0 + 1) (1 - w0)/(w0 + 1)];
    g(end) = w0/(w0+1);
end


% [EOF]
