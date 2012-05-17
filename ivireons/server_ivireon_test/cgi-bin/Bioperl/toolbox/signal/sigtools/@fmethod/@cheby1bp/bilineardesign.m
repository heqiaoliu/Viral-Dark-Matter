function [s,g] = bilineardesign(h,has,c)
%BILINEARDESIGN  Design digital filter from analog specs. using bilinear. 

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:51:48 $

N = has.FilterOrder;
if rem(N,2) == 1,
    error(generatemsgid('oddOrder'),...
        'Filter order must be an even integer.');
end
if rem(N,4) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('twiceEvenOrder'),...
        'Half of the filter order must be an odd integer for the filter structure specified.');
end

wp = has.Wpass;
rp = has.Apass;

% Compute Chebyshev I coeffs
[num,a1,w0] = cheby1coeffs(h,N/2,wp,rp);

% Compute den coeffs
den = 1+a1+num;
ai1 = 4*c*(-a1/2-1)./den;
ai2 = 2*(2*c^2+1-num)./den;
ai3 = -2*c*(2-a1)./den;
ai4 = (1+num-a1)./den;

fog = (num)./den; %Fourth-order gains

% Initialize matrix
[s,g] = sosinitbpbs(h,N,ai1,ai2,ai3,ai4,fog);

% Set all numerators
msf = 2*floor(N/4);
s(1:msf,1:3) = repmat([1 0 -1],msf,1);

if rem(N,4),
    s(end,1:3) = [1 0 -1];
    s(end,4:6) = [1 -2*c/(w0 + 1) (1 - w0)/(w0 + 1)];
    g(end) = w0/(w0+1);
else
    g(end+1) = sqrt(10^(-rp/10));
end


% [EOF]
