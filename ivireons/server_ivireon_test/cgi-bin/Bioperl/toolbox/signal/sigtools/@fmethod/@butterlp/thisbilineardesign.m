function [s,g] = thisbilineardesign(h,has,c)
%THISBILINEARDESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:51:25 $

N = has.FilterOrder;
if rem(N,2) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('evenOrder'),'Order must be odd for the filter structure specified.');
end

wc = has.Wcutoff;

% Initialize sos matrix and scale values
[s,g] = sosinitlphp(h,N);
ms = ceil(N/2);
msf = floor(N/2);

% Set common denominator part
[s,g] = setden(h,s,g,N,msf,wc);

% Set all numerators, make it an exact two
s(1:msf,2) = repmat(2,msf,1);

if rem(N,2),
    s(end,2) = 1;
    s(end,5) = (wc - 1)/(wc + 1);
    g(end) = wc/(wc+1);
end

%--------------------------------------------------------------------------
function [s,g] = setden(h,s,g,N,msf,wc)
% Set common denominator part

% Compute common used values once
wcsq = wc^2;
wc2 = 2*wc;

% Compute cosine of angles of stable butterworth poles
cs = costheta(h,N);

wc2cs = wc2*cs;

den = (1-wc2cs+wcsq);

% Set second denominator coefficient
s(1:msf,5) = 2*(wcsq-1)./den;

% Set 3rd denominator coefficient
s(1:msf,6) = (1+wc2cs+wcsq)./den;

g(1:msf) = wcsq./den;


% [EOF]
