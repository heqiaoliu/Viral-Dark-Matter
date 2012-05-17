function y = eml_scalar_pow2(a,b)
%Embedded MATLAB Library Function

%   Copyright 2005-2007 The MathWorks, Inc.
%#eml

if nargin == 1
    y = power(2,a);
else
    y = eml_ldexp(a,b);
end

