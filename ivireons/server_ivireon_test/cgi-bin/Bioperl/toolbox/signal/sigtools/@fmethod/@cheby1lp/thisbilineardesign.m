function [s,g] = thisbilineardesign(h,has,c)
%THISBILINEARDESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:52:55 $

N = has.FilterOrder;
if rem(N,2) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('evenOrder'),'Filter order must be odd for the filter structure specified.');
end

wp = has.Wpass;
rp = has.Apass;

% Initialize sos matrix and scale values
[s,g] = sosinitlphp(h,N);
ms = ceil(N/2);
msf = floor(N/2);

% Set common denominator part
[s,g,w0] = setden(h,s,g,N,msf,wp,rp);

% Set all numerators, make it an exact two
s(1:msf,2) = repmat(2,msf,1);

if rem(N,2),
    s(end,2) = 1;
    s(end,5) = (w0 - 1)/(w0 + 1);
    g(end) = w0/(w0+1);
else
    g(end+1) = sqrt(10^(-rp/10));
end

%--------------------------------------------------------------------------
function [s,g,w0] = setden(h,s,g,N,msf,wp,rp)
% Set common denominator part

[num,a1,w0] = cheby1coeffs(h,N,wp,rp);

den = 1+a1+num;

% Set denominators
s(1:msf,5) = 2*(num-1)./den;
s(1:msf,6) = (1-a1+num)./den;

% Set gains
g(1:msf) = num./den;


% [EOF]
