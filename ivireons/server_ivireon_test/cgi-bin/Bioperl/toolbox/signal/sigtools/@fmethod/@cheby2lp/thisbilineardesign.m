function [s,g] = thisbilineardesign(h,has,c)
%THISBILINEARDESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:54:23 $


N = has.FilterOrder;
if rem(N,2) == 0 && any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    error(generatemsgid('evenOrder'),'Order must be odd for the filter structure specified.');
end

ws = has.Wstop;
rs = has.Astop;

% Initialize sos matrix and scale values
[s,g] = sosinitlphp(h,N);
ms = ceil(N/2);
msf = floor(N/2);

[b0,a1,a0,w0] = cheby2coeffs(h,N,ws,rs);

% Set numerators
s = setnum(h,s,msf,b0);

% Set denominators
[s,g] = setden(h,s,g,msf,a1,a0,b0);

if rem(N,2),
    s(end,2) = 1;
    s(end,5) = (w0 - 1)/(w0 + 1);
    g(end) = w0/(w0+1);
end

%--------------------------------------------------------------------------
function s = setnum(h,s,msf,b0)
bi1 = 2*(1-b0)./(1+b0);
s(1:msf,2) = bi1;

%--------------------------------------------------------------------------
function [s,g] = setden(h,s,g,msf,a1,a0,b0)
% Set common denominator part

den = 1+a1+a0;

% Set denominators
s(1:msf,5) = 2*(1-a0)./den;
s(1:msf,6) = (1-a1+a0)./den;

% Set gains
g(1:msf) = (1+b0)./den;

% [EOF]
