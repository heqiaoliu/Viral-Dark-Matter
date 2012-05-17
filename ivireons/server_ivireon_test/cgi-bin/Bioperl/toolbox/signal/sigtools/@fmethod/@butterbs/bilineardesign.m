function [s,g] = bilineardesign(h,has,c)
%BILINEARDESIGN  Design digital filter from analog specs. using bilinear. 

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:50:29 $

N = has.FilterOrder;
if rem(N,2) == 1,
    error(generatemsgid('oddOrder'),...
        'Filter order must be an even integer.');
end
if rem(N,4) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('twiceEvenOrder'),...
        'Half of the filter order must be an odd integer for the filter structure specified.');
end

wc = has.Wcutoff;

% Compute cos of stable poles
cs = costheta(h,N/2);


% Compute den coeffs
wccs = wc*cs;
wccs2 = 2*wc*cs;
wc2 = wc^2;
den = 1-wccs2+wc2;
ai1 = 4*c*wc*(cs-wc)./den;
ai2 = 2*(2*c^2*wc2+wc2-1)./den;
ai3 = -4*c*wc*(cs+wc)./den;
ai4 = (1+wccs2+wc2)./den;

fog = wc2./den; % Fourth-order gains

% Initialize matrix
[s,g] = sosinitbpbs(h,N,ai1,ai2,ai3,ai4,fog);

% Set all numerators
msf = 2*floor(N/4);
s(1:msf,1:3) = repmat([1 -2*c 1],msf,1);

if rem(N,4),
    s(end,1:3) = [1 -2*c 1];
    s(end,4:6) = [1 -2*c*wc/(wc + 1) -(1 - wc)/(wc + 1)];
    g(end) = wc/(wc+1);
end

% [EOF]
