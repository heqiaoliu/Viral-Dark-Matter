function p = eml_scalar_nextpow2(n)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml 

absn = eml_scalar_abs(n);
if isfinite(absn)
    [f,p] = eml_scalar_log2(absn);
    % Check if n is an exact power of 2.
    if f == 0.5
        p = p-1;
    end
else
    p = absn;
end
