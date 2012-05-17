function y = eml_scalar_nthroot(x,n)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml
if x < 0
    y = -power(-x,eml_rdivide(1,n));
else
    y = power(x,eml_rdivide(1,n));
end
if isfinite(y) && isfinite(n) && x ~= 0
    y2n = y .^ n;
    d = y2n - x;
    if d ~= 0 % Example: nthroot(64,3)
        % Reduce numerical errors with one iteration of Newton's method.
        y = y - eml_rdivide(d,n.*eml_rdivide(y2n,y));
    end
end
