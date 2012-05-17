function x = eml_scalar_log10(x)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_log10(x);
else
    % Compute y = log2(x)/log2(10) with an averaging process so that roundoff
    % errors cancel and log10(10^k) == k for all integers k = -307:308.
    % Use y = log2(x)/c1 + log2(x)/c2 where c1 = 2*log2(10)+2.5*eps,
    % c2 = 2*log2(10)-1.5*eps are successive floating point numbers on
    % either side of 2*log2(10).
    x = eml_scalar_log2(x);
    x = eml_div(x,6.64385618977472436) + eml_div(x,6.64385618977472525);
end
