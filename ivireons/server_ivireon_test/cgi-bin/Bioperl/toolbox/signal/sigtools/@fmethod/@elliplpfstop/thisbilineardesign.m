function [s,g] = thisbilineardesign(h,N,sa,ga)
%THISBILINEARDESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:56:17 $

% Initialize sos matrix and scale values
[s,g] = sosinitlphp(h,N);
ms = ceil(N/2);
msf = floor(N/2);

for k = 1:msf,
    den = sa(k,4)+sa(k,5)+sa(k,6);
    b0 = (sa(k,1)+sa(k,3))./den;
    b1 = 2*(sa(k,3)-sa(k,1))./den;
    a1 = 2*(sa(k,6)-sa(k,1))./den;
    a2 = (sa(k,6)+sa(k,4)-sa(k,5))./den;
    s(k,[2 5 6]) = [b1/b0, a1, a2];
    g(k) = b0*ga(k);
end

if rem(N,2),
    % First order section
    den = sa(ms,5)+sa(ms,6);
    b0 = sa(ms,3)/den;
    a1 = (sa(ms,6)-sa(ms,5))/den;
    s(ms,[1,2,5]) = [1, 1, a1];
    g(ms) = b0;
end

% Special case 1st order case
if N == 1,
    g = g*ga;
end

% [EOF]
